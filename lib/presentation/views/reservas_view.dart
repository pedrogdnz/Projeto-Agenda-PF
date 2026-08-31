import 'package:flutter/material.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';
import 'package:agendapf/presentation/widgets/filtro_tabs.dart';
import 'package:agendapf/presentation/widgets/reserva_card.dart';

class Reservas extends StatefulWidget {
  final String alunoId;

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
      agendaRepository: widget.agendaRepository,
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
                    FiltroTabs<TipoFiltroReserva>(
                      filtroAtual: _viewModel.filtroAtual,
                      opcoes: const {
                        TipoFiltroReserva.ativas: 'Ativas',
                        TipoFiltroReserva.passadas: 'Passadas',
                      },
                      onFiltroChanged: _viewModel.alterarFiltro,
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: _viewModel.carregando
                          ? const Center(child: CircularProgressIndicator())
                          : _viewModel.reservasFiltradas.isEmpty
                          ? EmptyStateView(
                              icon: Icons.event_busy,
                              message:
                                  _viewModel.filtroAtual ==
                                      TipoFiltroReserva.ativas
                                  ? 'Nenhuma reserva ativa encontrada'
                                  : 'Nenhuma reserva passada encontrada',
                            )
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
          onPressed: () async {
            Navigator.pop(ctx);
            final sucesso = await _viewModel.cancelarReserva(reservaId);
            if (!sucesso && context.mounted) { // trocado: mounted → context.mounted
              final erro = _viewModel.erro;
              if (erro != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(erro)));
              }
            }
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