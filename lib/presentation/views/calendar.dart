import 'package:agendapf/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:agendapf/presentation/views/detalhes.dart';
import 'package:agendapf/presentation/views/reservas.dart';
import 'package:agendapf/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = CalendarViewModel();
    _viewModel.addListener(_handleViewModelChange);
  }

  void _handleViewModelChange() {
    final dayToOpen = _viewModel.dayToOpen;

    if (dayToOpen != null) {
      _viewModel.clearDayToOpen();

      // Garante que a navegação só ocorra APÓS o frame atual terminar de desenhar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Detalhes(data: dayToOpen)),
        );
      });
    }

    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();

    super.dispose();
  }

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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Calendário",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.person),
                      tooltip: 'Ver reservas',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Reservas()),
                        );
                      },
                    ),
                  ],
                ),
                const Text("Selecione uma data:"),
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

                    focusedDay: _viewModel.focusedDay,
                    calendarFormat: _viewModel.calendarFormat,

                    selectedDayPredicate: (day) {
                      return isSameDay(_viewModel.selectedDay, day);
                    },

                    onDaySelected: (selectedDay, focusedDay) {
                      _viewModel.selectDay(selectedDay, focusedDay);
                    },

                    onFormatChanged: (format) {
                      _viewModel.changeFormat(format);
                    },

                    onPageChanged: (focusedDay) {
                      _viewModel.changePage(focusedDay);
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

                  const Text("Teste de funcionamento calendário:"),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _viewModel.selectedDay != null
                        ? Container(
                            key: ValueKey(_viewModel.selectedDay),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Data selecionada: "
                              "${_viewModel.selectedDay!.day}/"
                              "${_viewModel.selectedDay!.month}/"
                              "${_viewModel.selectedDay!.year}",
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
