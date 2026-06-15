import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendapf/presentation/utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
      ),
      backgroundColor: Colors.white,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20,0,20,0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Calendário",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Text("Selecione uma data:"),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20,0,20,20),
          
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
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
