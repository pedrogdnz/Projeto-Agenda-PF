import 'package:agendapf/presentation/views/detalhes.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendapf/presentation/utils.dart';
import 'package:agendapf/presentation/views/reservas.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastTappedDay;
  DateTime? _lastTapTime;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [],
      ),
      backgroundColor: Colors.white,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Calendário",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(child: Container()),
                    IconButton(
                      icon: Icon(Icons.person),
                      tooltip: 'Ver reservas',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Reservas()),
                        );
                      },
                    ),
                  ],
                ),
                Text("Selecione uma data:"),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 8),

                  const SizedBox(height: 24),

                  TableCalendar(
                    locale: 'pt_BR',

                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,

                    calendarFormat: _calendarFormat,

                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },

                    onDaySelected: (selectedDay, focusedDay) {
                      final now = DateTime.now();

                      if (_lastTappedDay != null &&
                          isSameDay(_lastTappedDay, selectedDay) &&
                          _lastTapTime != null &&
                          now.difference(_lastTapTime!).inMilliseconds < 500) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Detalhes(data: selectedDay),
                          ),
                        );
                      }

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      _lastTappedDay = selectedDay;
                      _lastTapTime = now;
                    },

                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },

                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,

                      titleCentered: false,

                      titleTextStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),

                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.black54,
                      ),

                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.black54,
                      ),
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

                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,

                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        shape: BoxShape.circle,
                      ),

                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF3F51B5),
                        shape: BoxShape.circle,
                      ),

                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                      todayTextStyle: const TextStyle(color: Colors.white),

                      outsideTextStyle: TextStyle(color: Colors.grey.shade400),

                      defaultTextStyle: const TextStyle(color: Colors.black87),

                      weekendTextStyle: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Teste de funcionamento calendário:"),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedDay != null
                        ? Container(
                            key: ValueKey(_selectedDay),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Data selecionada: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
