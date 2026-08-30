import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart'; // novo import
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

  Map<DateTime, MotivoBloqueio> _diasBloqueados = {};
  bool _carregandoDiasBloqueados = true;

  List<HorarioDoDia> _horariosDoDiaSelecionado = [];
  bool _carregandoHorarios = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get dayToOpen => _dayToOpen;
  String? get erroSelecao => _erroSelecao;
  bool get carregandoDiasBloqueados => _carregandoDiasBloqueados;
  List<HorarioDoDia> get horariosDoDiaSelecionado => _horariosDoDiaSelecionado;
  bool get carregandoHorarios => _carregandoHorarios;
  Map<DateTime, MotivoBloqueio> get diasBloqueados => _diasBloqueados;
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
    notifyListeners();

    _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();

    _carregandoDiasBloqueados = false;
    notifyListeners();
  }

  bool diaSelecionavel(DateTime dia) {
    return _agendaRepository.diaSelecionavel(dia, _diasBloqueados);
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!diaSelecionavel(selectedDay)) {
      _erroSelecao = 'Esta data não está disponível para reserva.';
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

    _horariosDoDiaSelecionado = await _agendaRepository.buscarHorariosDoDia(
      dia,
    );

    _carregandoHorarios = false;
    notifyListeners();
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
