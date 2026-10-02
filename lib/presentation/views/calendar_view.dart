import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/presentation/utils/motivo_bloqueio_cor.dart';
import 'package:agendapf/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:agendapf/presentation/views/detalhes_view.dart';
import 'package:agendapf/presentation/views/reservas_view.dart';
import 'package:agendapf/core/utils/utils.dart';
import 'package:agendapf/presentation/widgets/calendar_legenda.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agendapf/presentation/views/aluno_perfil_view.dart';

class CalendarPage extends StatefulWidget {
  final CalendarViewModel viewModel;
  final String alunoId;
  final AuthRepository authRepository; // NOVO

  const CalendarPage({
    super.key,
    required this.viewModel,
    required this.alunoId,
    required this.authRepository, // NOVO
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlunoPerfil(
          alunoId: widget.alunoId,
          authRepository: widget.authRepository,
        ),
      ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Calendário",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text("Selecione uma data", style: TextStyle(fontSize: 14)),
          
              const SizedBox(height: 24),
          
              AnimatedBuilder(
                animation: _viewModel,
                builder: (context, _) {
                  if (_viewModel.carregandoDiasBloqueados) {
                    return const Center(child: LinearProgressIndicator());
                  }
          
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                        child: TableCalendar(
                          calendarBuilders: CalendarBuilders(
                            disabledBuilder: (context, day, focusedDay) {
                              final motivo = _viewModel.motivoBloqueioPara(day);
                              if (motivo == null) return null;
          
                              return Container(
                                margin: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: corParaMotivoBloqueio(motivo),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          locale: 'pt_BR',
          
                          firstDay: kFirstDay,
                          lastDay: kLastDay,
          
                          focusedDay: _viewModel.focusedDay,
                          calendarFormat: CalendarFormat.month,
          
                          availableGestures: AvailableGestures.horizontalSwipe,
          
                          enabledDayPredicate: (day) =>
                              _viewModel.diaSelecionavel(day),
          
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
                            titleCentered: true,
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
          
                            outsideTextStyle: TextStyle(
                              color: Colors.grey.shade400,
                            ),
          
                            defaultTextStyle: const TextStyle(
                              color: Colors.black87,
                            ),
          
                            weekendTextStyle: const TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
          
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CalendarLegenda(
                          motivosPresentes:
                              _viewModel.motivosBloqueioDoMesVisivel,
                        ),
                      ),
          
                      const SizedBox(height: 16),
          
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _abrirReservas,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FC),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: Color(0xFF3F51B5),
                                  size: 26,
                                ),
                              ),
          
                              const SizedBox(width: 14),
          
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Minhas reservas',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
          
                                    SizedBox(height: 4),
          
                                    Text(
                                      'Consulte suas reservas e detalhes',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
          
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
