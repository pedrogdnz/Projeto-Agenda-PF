import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;
  DateTime? _dayToOpen;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime? get dayToOpen => _dayToOpen;

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
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
      print("Você clicou duas vezes");
    }
    _lastTappedDay = selectedDay;
    _lastTapTime = now;

    notifyListeners();
  }

  void clearDayToOpen() {
    _dayToOpen = null;
    print("ClearDayToOpen");
  }

  void changeFormat(CalendarFormat format) {
    _calendarFormat = format;
    print("ChangeFormat");
    notifyListeners();
  }

  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    print("ChangePage");
    notifyListeners();
  }
}
