import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository;

  CalendarViewModel({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;
  DateTime? _dayToOpen;

  CalendarFormat _calendarFormat = CalendarFormat.month;

    Set<DateTime> _diasBloqueados = {};
  bool _carregandoDiasBloqueados = true;

    List<HorarioDoDia> _horariosDoDiaSelecionado = [];
  bool _carregandoHorarios = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime? get dayToOpen => _dayToOpen;

  bool get carregandoDiasBloqueados => _carregandoDiasBloqueados;

  List<HorarioDoDia> get horariosDoDiaSelecionado => _horariosDoDiaSelecionado;

  bool get carregandoHorarios => _carregandoHorarios;

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
    if (!diaSelecionavel(selectedDay)) return;

    final now = DateTime.now();

    _dayToOpen = null;

    final bool isDoubleTap =
        _lastTappedDay != null &&
        isSameDay(_lastTappedDay, selectedDay) &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500;

    _selectedDay = selectedDay;
    _focusedDay = focusedDay;

    if (isDoubleTap) {
      _dayToOpen = selectedDay;
    }

    _lastTappedDay = selectedDay;
    _lastTapTime = now;

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

  void changeFormat(CalendarFormat format) {
    _calendarFormat = format;
    notifyListeners();
  }

  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }
}
