import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/services/agenda_data_source.dart';

/// Cor de fundo usada para sinalizar visualmente o status de um horário em
/// um dia específico (RF04): preto para indisponível/reservado, branco para
/// disponível. Diferente do que fizemos antes, isso agora é calculado
/// dinamicamente pelo repository — não é um campo fixo do [Horario].
enum CorFundoHorario { preto, branco }

/// Um [Horario] do catálogo já com o status calculado para um dia
/// específico (disponível ou já reservado). É o que a tela de detalhes do
/// dia deve consumir para montar a lista de horários (RF04).
class HorarioDoDia {
  final Horario horario;
  final bool disponivel;
  final CorFundoHorario corFundo;

  const HorarioDoDia({
    required this.horario,
    required this.disponivel,
    required this.corFundo,
  });
}

/// Repositório de consultas e filtros do calendário/agenda para o aluno.
///
/// Consome os services de leitura crua e aplica as regras:
/// - RF03 / RN05: o calendário só deve permitir selecionar dias que não
///   foram bloqueados pelo administrador.
/// - RF04: retorna os horários (do catálogo fixo) vinculados a uma data,
///   já com o status de disponibilidade calculado.
/// - RN04: nenhuma data ou horário passado pode ser listado ou selecionado.
class AgendaRepository {
  final DataBloqueadaService _dataBloqueadaService;
  final HorarioService _horarioService;
  final ReservaService _reservaService;

  const AgendaRepository({
    required DataBloqueadaService dataBloqueadaService,
    required HorarioService horarioService,
    required ReservaService reservaService,
  }) : _dataBloqueadaService = dataBloqueadaService,
       _horarioService = horarioService,
       _reservaService = reservaService;

  /// RF03 / RN05: retorna o conjunto de dias bloqueados pelo admin,
  /// normalizados (sem hora), para consulta rápida (ex: em um
  /// `enabledDayPredicate` do table_calendar).
  Future<Set<DateTime>> buscarDiasBloqueados() async {
    final registros = await _dataBloqueadaService.buscarTodas();
    return registros
        .where((d) => d.bloqueado)
        .map((d) => _normalizarData(d.data))
        .toSet();
  }

  /// RN04 + RN05: diz se um [dia] pode ser selecionado no calendário.
  ///
  /// Recebe o conjunto de [diasBloqueados] (obtido via
  /// [buscarDiasBloqueados]) para não precisar buscar no banco a cada dia
  /// renderizado pelo table_calendar.
  bool diaSelecionavel(DateTime dia, Set<DateTime> diasBloqueados) {
    final hoje = _normalizarData(DateTime.now());
    final diaNormalizado = _normalizarData(dia);

    if (diaNormalizado.isBefore(hoje)) return false; // RN04
    if (diasBloqueados.contains(diaNormalizado)) return false; // RN05

    return true;
  }

  /// RF04 + RN04: retorna os horários vinculados ao [dia] informado, já com
  /// o status de disponibilidade calculado (reservado ou não).
  ///
  /// Retorna lista vazia se o dia for passado ou estiver bloqueado. Se o
  /// dia for hoje, horários cuja hora inicial já passou são excluídos.
  Future<List<HorarioDoDia>> buscarHorariosDoDia(DateTime dia) async {
    final diaNormalizado = _normalizarData(dia);
    final diasBloqueados = await buscarDiasBloqueados();

    if (!diaSelecionavel(diaNormalizado, diasBloqueados)) {
      return const [];
    }

    final horarios = await _horarioService.buscarTodos();
    final reservasDoDia = await _reservaService.buscarPorData(diaNormalizado);
    final idsReservados = reservasDoDia.map((r) => r.horarioId).toSet();

    final agora = DateTime.now();
    final ehHoje = _normalizarData(agora) == diaNormalizado;

    return horarios
        .where((horario) {
          if (!ehHoje) return true;
          final inicio = _combinarDataEHora(
            diaNormalizado,
            horario.horaInicial,
          );
          return inicio.isAfter(agora); // RN04: horário passado não é listado
        })
        .map((horario) {
          final reservado = idsReservados.contains(horario.id);
          return HorarioDoDia(
            horario: horario,
            disponivel: !reservado,
            corFundo: reservado
                ? CorFundoHorario.preto
                : CorFundoHorario.branco,
          );
        })
        .toList();
  }

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  /// Combina um dia com uma hora no formato "HH:mm" em um único DateTime,
  /// para poder comparar com `DateTime.now()`.
  DateTime _combinarDataEHora(DateTime dia, String horaHHmm) {
    final partes = horaHHmm.split(':');
    final hora = int.parse(partes[0]);
    final minuto = partes.length > 1 ? int.parse(partes[1]) : 0;
    return DateTime(dia.year, dia.month, dia.day, hora, minuto);
  }
}
