import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';
import 'package:agendapf/presentation/utils/motivo_bloqueio_cor.dart';
import 'package:flutter/material.dart';
import 'package:agendapf/core/utils/utils.dart';
import 'package:agendapf/data/models/enum/tipo_configuracao_ano_letivo.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendário da Configuração do Ano Letivo (admin). Semelhante ao
/// calendário do aluno, mas com dois modos extras de seleção:
/// - Férias: arrastar o dedo seleciona ou desmarca várias datas consecutivas (vermelho).
/// - Feriados: tocar em cada data alterna sua seleção individualmente (azul).

class AnoLetivoCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final TipoConfiguracaoAnoLetivo? modoAtivo;
  final Set<DateTime> datasSelecionadas;
  final Map<DateTime, MotivoBloqueio> diasBloqueados;
  final bool Function(DateTime dia) diaSelecionavel;
  final ValueChanged<DateTime> onDataArrastada;
  final ValueChanged<DateTime> onDataTocada;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<DateTime> onDataBloqueadaTocada;

  const AnoLetivoCalendar({
    super.key,
    required this.focusedDay,
    required this.modoAtivo,
    required this.datasSelecionadas,
    required this.diasBloqueados,
    required this.diaSelecionavel,
    required this.onDataArrastada,
    required this.onDataTocada,
    required this.onPageChanged,
    required this.onDataBloqueadaTocada,
  });

  @override
  State<AnoLetivoCalendar> createState() => _AnoLetivoCalendarState();
}

class _AnoLetivoCalendarState extends State<AnoLetivoCalendar> {
  // Guarda a chave de cada célula visível para o hit-test durante o
  // arraste (modo Férias). É repopulado a cada build do mês visível.
  final Map<DateTime, GlobalKey> _chavesPorDia = {};
  DateTime? _ultimoDiaArrastado;
  bool?
  _desmarcandoAoArrastar; // Define se o gesto atual está marcando ou desmarcando

  bool get _modoFerias => widget.modoAtivo == TipoConfiguracaoAnoLetivo.ferias;
  bool get _modoFeriados =>
      widget.modoAtivo == TipoConfiguracaoAnoLetivo.feriados;

  DateTime _normalizar(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  void _handlePonteiro(Offset posicaoGlobal) {
    if (!_modoFerias) return;

    for (final entrada in _chavesPorDia.entries) {
      final contexto = entrada.value.currentContext;
      if (contexto == null) continue;

      final renderBox = contexto.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) continue;

      final posicaoLocal = renderBox.globalToLocal(posicaoGlobal);
      final areaCelula = Offset.zero & renderBox.size;

      if (areaCelula.contains(posicaoLocal)) {
        final dia = entrada.key;
        if (_ultimoDiaArrastado == dia) return;

        // Define a ação do gesto (marcar ou desmarcar) com base no primeiro dia tocado
        _desmarcandoAoArrastar ??= widget.datasSelecionadas.contains(dia);

        _ultimoDiaArrastado = dia;

        final jaSelecionado = widget.datasSelecionadas.contains(dia);

        // Dispara a callback para alternar o estado do dia conforme a intenção do gesto
        if (_desmarcandoAoArrastar! && jaSelecionado) {
          widget.onDataArrastada(dia);
        } else if (!_desmarcandoAoArrastar! && !jaSelecionado) {
          widget.onDataArrastada(dia);
        }
        return;
      }
    }
  }

  Color? _corDaData(DateTime dia) {
    final diaNormalizado = _normalizar(dia);

    if (widget.datasSelecionadas.contains(diaNormalizado)) {
      return _modoFerias ? Colors.red : Colors.blue;
    }

    final motivoExistente = widget.diasBloqueados[diaNormalizado];
    if (motivoExistente != null) {
      return corParaMotivoBloqueio(motivoExistente);
    }

    return null;
  }

  Widget _celulaDia(DateTime dia, {bool ehHoje = false}) {
    final diaNormalizado = _normalizar(dia);
    final chave = _chavesPorDia.putIfAbsent(diaNormalizado, () => GlobalKey());
    final corSelecao = _corDaData(dia);

    return Container(
      key: chave,
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: corSelecao ?? (ehHoje ? Colors.blue.shade100 : null),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${dia.day}',
        style: TextStyle(
          color: corSelecao != null ? Colors.white : Colors.black87,
          fontWeight: ehHoje ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _celulaDesabilitada(DateTime dia) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Text(
        '${dia.day}',
        style: TextStyle(
          color: Colors.grey.shade400,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    );
  }

  void _limparEstadoPonteiro() {
    _ultimoDiaArrastado = null;
    _desmarcandoAoArrastar = null;
  }

  @override
  Widget build(BuildContext context) {
    _chavesPorDia.clear();

    return Listener(
      onPointerDown: (e) => _handlePonteiro(e.position),
      onPointerMove: (e) => _handlePonteiro(e.position),
      onPointerUp: (_) => _limparEstadoPonteiro(),
      onPointerCancel: (_) => _limparEstadoPonteiro(),
      child: TableCalendar(
        locale: 'pt_BR',
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: widget.focusedDay,
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.none,
        enabledDayPredicate: (day) => widget.diaSelecionavel(day),
        selectedDayPredicate: (_) => false,
        onDaySelected: (selectedDay, focusedDay) {
          final dia = _normalizar(selectedDay);

          if (widget.diasBloqueados.containsKey(dia)) {
            widget.onDataBloqueadaTocada(dia);
            return;
          }

          if (_modoFeriados) {
            widget.onDataTocada(dia);
          }
        },
        onPageChanged: widget.onPageChanged,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black54),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black54),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _celulaDia(day),
          todayBuilder: (context, day, focusedDay) =>
              _celulaDia(day, ehHoje: true),
          disabledBuilder: (context, day, focusedDay) =>
              _celulaDesabilitada(day),
        ),
      ),
    );
  }
}
