import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository;

  CalendarViewModel({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  AgendaRepository get agendaRepository => _agendaRepository;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _dayToOpen;

  String? _erroSelecao;
  String? _erroCarregamento;

  Map<DateTime, MotivoBloqueio> _diasBloqueados = {};
  Set<DiaSemana>? _diasSemanaAtivos; // null = ainda não carregado
  bool _carregandoDiasBloqueados = true;

  List<HorarioDoDia> _horariosDoDiaSelecionado = [];
  bool _carregandoHorarios = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get dayToOpen => _dayToOpen;
  String? get erroSelecao => _erroSelecao;
  String? get erroCarregamento => _erroCarregamento;
  bool get carregandoDiasBloqueados => _carregandoDiasBloqueados;
  List<HorarioDoDia> get horariosDoDiaSelecionado => _horariosDoDiaSelecionado;
  bool get carregandoHorarios => _carregandoHorarios;
  Map<DateTime, MotivoBloqueio> get diasBloqueados => _diasBloqueados;

  /// true quando o admin ainda não liberou horário em nenhum dia da semana.
  /// Use na tela para mostrar um aviso em vez de só riscar todas as datas.
  bool get semHorariosConfigurados =>
      !_carregandoDiasBloqueados &&
      _erroCarregamento == null &&
      _diasSemanaAtivos != null &&
      _diasSemanaAtivos!.isEmpty;

  Set<MotivoBloqueio> get motivosBloqueioDoMesVisivel {
    return _diasBloqueados.entries
        .where(
          (entrada) =>
              entrada.key.year == _focusedDay.year &&
              entrada.key.month == _focusedDay.month,
        )
        .map((entrada) => entrada.value)
        .toSet();
  }

  MotivoBloqueio? motivoBloqueioPara(DateTime dia) {
    return _diasBloqueados[DateTime(dia.year, dia.month, dia.day)];
  }

  Future<void> carregarDiasBloqueados() async {
    _carregandoDiasBloqueados = true;
    _erroCarregamento = null;
    notifyListeners();

    try {
      _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();
      _diasSemanaAtivos = await _agendaRepository.buscarDiasSemanaAtivos();
    } catch (e) {
      _erroCarregamento = e.toString();
    } finally {
      _carregandoDiasBloqueados = false;
      notifyListeners();
    }
  }

  bool diaSelecionavel(DateTime dia) {
    return _agendaRepository.diaSelecionavel(
      dia,
      _diasBloqueados,
      diasSemanaAtivos: _diasSemanaAtivos,
    );
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!diaSelecionavel(selectedDay)) {
      _erroSelecao = semHorariosConfigurados
          ? 'O laboratório ainda não tem horários configurados.'
          : 'Esta data não está disponível para reserva.';
      notifyListeners();
      return;
    }

    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _dayToOpen = selectedDay;

    notifyListeners();

    carregarHorariosDoDia(selectedDay);
  }

  Future<void> carregarHorariosDoDia(DateTime dia) async {
    _carregandoHorarios = true;
    notifyListeners();

    try {
      _horariosDoDiaSelecionado = await _agendaRepository.buscarHorariosDoDia(
        dia,
      );
    } catch (e) {
      _horariosDoDiaSelecionado = [];
      _erroSelecao = e.toString();
    } finally {
      _carregandoHorarios = false;
      notifyListeners();
    }
  }

  void clearDayToOpen() {
    _dayToOpen = null;
  }

  void limparErroSelecao() {
    _erroSelecao = null;
  }

  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }
}