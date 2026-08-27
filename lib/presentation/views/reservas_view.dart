import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';

class Reservas extends StatefulWidget {
  final String alunoId;

  /// Mesmo AgendaRepository usado no Calendário/Detalhes — garante que o
  /// ReservasViewModel enxergue exatamente as mesmas reservas em memória
  final AgendaRepository agendaRepository;

  const Reservas({
    super.key,
    required this.alunoId,
    required this.agendaRepository,
  });

  @override
  State<Reservas> createState() => _ReservasState();
}

class _ReservasState extends State<Reservas> {
  late final ReservasViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReservasViewModel(
      alunoId: widget.alunoId,
      reservaService: widget.agendaRepository.reservaService,
      horarioService: widget.agendaRepository.horarioService,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarReservas();
  }

  void _handleViewModelChange() {
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
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Minhas Reservas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _FiltroTabs(
                      filtroAtual: _viewModel.filtroAtual,
                      onFiltroChanged: _viewModel.alterarFiltro,
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: _viewModel.carregando
                          ? const Center(child: CircularProgressIndicator())
                          : _viewModel.reservasFiltradas.isEmpty
                          ? const _EmptyStateView()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _viewModel.reservasFiltradas.length,
                              itemBuilder: (context, index) {
                                final item =
                                    _viewModel.reservasFiltradas[index];
                                final isPassada =
                                    _viewModel.filtroAtual ==
                                    TipoFiltroReserva.passadas;

                                return ReservaCard(
                                  item: item,
                                  isPassada: isPassada,
                                  onCancelar: () => _confirmarCancelamento(
                                    context,
                                    item.reserva.id,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarCancelamento(BuildContext context, String reservaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('Tem certeza de que deseja cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.cancelarReserva(reservaId);
            },
            child: const Text(
              'Sim, cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroTabs extends StatelessWidget {
  final TipoFiltroReserva filtroAtual;
  final ValueChanged<TipoFiltroReserva> onFiltroChanged;

  const _FiltroTabs({required this.filtroAtual, required this.onFiltroChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Ativas')),
              selected: filtroAtual == TipoFiltroReserva.ativas,
              selectedColor: const Color(0xFF1E1E1E),
              labelStyle: TextStyle(
                color: filtroAtual == TipoFiltroReserva.ativas
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) => onFiltroChanged(TipoFiltroReserva.ativas),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Passadas')),
              selected: filtroAtual == TipoFiltroReserva.passadas,
              selectedColor: const Color(0xFF1E1E1E),
              labelStyle: TextStyle(
                color: filtroAtual == TipoFiltroReserva.passadas
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) => onFiltroChanged(TipoFiltroReserva.passadas),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservaCard extends StatelessWidget {
  final ReservaComHorario item;
  final bool isPassada;
  final VoidCallback onCancelar;

  const ReservaCard({
    super.key,
    required this.item,
    required this.isPassada,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final data = item.reserva.dataReserva;

    final diaSemana = DateFormat('EEE', 'pt_BR').format(data).toUpperCase();
    final mes = DateFormat('MMM', 'pt_BR').format(data).toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPassada
                        ? Colors.grey.shade200
                        : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isPassada
                              ? Colors.grey.shade700
                              : Colors.white,
                        ),
                      ),
                      Text(
                        '$mes • $diaSemana',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPassada
                              ? Colors.grey.shade600
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.palette_outlined,
                        text:
                            "Fundo: ${item.reserva.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco'}",
                      ),
                      if (item.reserva.descricao.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          text: item.reserva.descricao,
                        ),
                      ],
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: isPassada
                            ? Icons.history
                            : Icons.check_circle_outline,
                        iconColor: isPassada ? Colors.grey : Colors.green,
                        text: isPassada ? "Concluída" : "Confirmada",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (!isPassada) ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancelar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar Reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma reserva encontrada',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
