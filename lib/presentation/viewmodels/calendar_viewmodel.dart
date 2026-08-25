// lib/presentation/viewmodels/calendar_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/repositories/agenda_repository.dart';

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

  // --- RF03 / RN04 / RN05: dias bloqueados pelo admin -----------------
  Set<DateTime> _diasBloqueados = {};
  bool _isLoading = true;

  // --- RF04: horários do dia selecionado -------------------------------
  List<HorarioDoDia> _horariosDoDiaSelecionado = [];
  bool _carregandoHorarios = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime? get dayToOpen => _dayToOpen;

  /// True enquanto os dias bloqueados ainda estão sendo carregados.
  bool get isLoading => _isLoading;

  List<HorarioDoDia> get horariosDoDiaSelecionado => _horariosDoDiaSelecionado;
  bool get carregandoHorarios => _carregandoHorarios;

  /// RF03 / RN05: busca os dias bloqueados pelo admin para desabilitá-los
  /// no calendário. Deve ser chamado pela View ao iniciar a tela.
  Future<void> carregarDiasBloqueados() async {
    _isLoading = true;
    notifyListeners();

    _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();

    _isLoading = false;
    notifyListeners();
  }

  /// Usar direto em `TableCalendar(enabledDayPredicate: (day) => !isDiaBloqueado(day))`.
  /// Retorna true se o dia NÃO pode ser selecionado — combina RN04 (dia
  /// passado) e RN05 (dia bloqueado pelo admin).
  bool isDiaBloqueado(DateTime dia) {
    return !_agendaRepository.diaSelecionavel(dia, _diasBloqueados);
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    // Proteção extra além do enabledDayPredicate da UI (RN04/RN05).
    if (isDiaBloqueado(selectedDay)) return;

    final now = DateTime.now();
    _dayToOpen = null;

    final bool isDoubleTap =
        _lastTappedDay != null &&
        isSameDay(_lastTappedDay, selectedDay) &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500;
    //Existe um horário do clique anterior
    //E passaram menos de 500 milissegundos desde ele?

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

  /// RF04: busca os horários vinculados ao dia informado, já com o status
  /// de disponibilidade calculado (RN04 exclui horários passados de hoje).
  Future<void> carregarHorariosDoDia(DateTime dia) async {
    _carregandoHorarios = true;
    notifyListeners();

    _horariosDoDiaSelecionado = await _agendaRepository.buscarHorariosDoDia(dia);

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