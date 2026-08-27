import 'package:agendapf/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:agendapf/presentation/views/detalhes_view.dart';
import 'package:agendapf/presentation/views/reservas_view.dart';
import 'package:agendapf/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final CalendarViewModel viewModel;

  final String alunoId;

  const CalendarPage({
    super.key,
    required this.viewModel,
    required this.alunoId,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = widget.viewModel;

    _viewModel.addListener(_handleViewModelChange);

    _viewModel.carregarDiasBloqueados();
  }

  void _handleViewModelChange() {
    final dayToOpen = _viewModel.dayToOpen;
    final erro = _viewModel.erroSelecao;

    if (erro != null) {
      _viewModel.limparErroSelecao();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
      });
    }

    if (dayToOpen != null) {
      _viewModel.clearDayToOpen();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Detalhes(
              data: dayToOpen,
              alunoId: widget.alunoId,
              agendaRepository: _viewModel.agendaRepository,
            ),
          ),
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

  void _abrirReservas() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Reservas(
          alunoId: widget.alunoId,
          agendaRepository: _viewModel.agendaRepository,
        ),
      ),
    );
  }

  void _abrirPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tela de perfil ainda não implementada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Ver reservas',
          onPressed: _abrirReservas,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Perfil',
            onPressed: _abrirPerfil,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Calendário",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Selecione uma data:"),

            const SizedBox(height: 24),

            AnimatedBuilder(
              animation: _viewModel,
              builder: (context, _) {
                if (_viewModel.carregandoDiasBloqueados) {
                  return const Center(child: LinearProgressIndicator());
                }

                return TableCalendar(
                  locale: 'pt_BR',

                  firstDay: kFirstDay,
                  lastDay: kLastDay,

                  focusedDay: _viewModel.focusedDay,
                  calendarFormat: CalendarFormat.month,

                  availableGestures: AvailableGestures.horizontalSwipe,

                  enabledDayPredicate: (day) => _viewModel.diaSelecionavel(day),

                  selectedDayPredicate: (day) {
                    return isSameDay(_viewModel.selectedDay, day);
                  },

                  onDaySelected: (selectedDay, focusedDay) {
                    _viewModel.selectDay(selectedDay, focusedDay);
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

                    disabledTextStyle: TextStyle(
                      color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                    ),
                    disabledDecoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),

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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
