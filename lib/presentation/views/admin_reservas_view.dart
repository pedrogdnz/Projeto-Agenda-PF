import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/presentation/viewmodels/admin_reservas_viewmodel.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart'
    show TipoFiltroReserva;
import 'package:agendapf/presentation/views/admin_reserva_editar_view.dart';
import 'package:agendapf/presentation/widgets/admin_reserva_card.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';
import 'package:agendapf/presentation/widgets/filtro_tabs.dart';

class AdminReservasPage extends StatefulWidget {
  final AgendaRepository agendaRepository;
  final AlunoRepository alunoRepository;

  const AdminReservasPage({
    super.key,
    required this.agendaRepository,
    required this.alunoRepository,
  });

  @override
  State<AdminReservasPage> createState() => _AdminReservasPageState();
}

class _AdminReservasPageState extends State<AdminReservasPage> {
  late final AdminReservasViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminReservasViewModel(
      agendaRepository: widget.agendaRepository,
      alunoRepository: widget.alunoRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarReservas();
  }

  void _handleViewModelChange() {
    final erro = _viewModel.erro;
    if (erro != null) {
      _viewModel.limparErro();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
      });
    }

    final info = _viewModel.mensagemInfo;
    if (info != null) {
      _viewModel.limparMensagemInfo();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(info)));
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

  Future<void> _editar(ReservaDoAluno item) async {
    final atualizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminReservaEditarPage(
          item: item,
          agendaRepository: widget.agendaRepository,
        ),
      ),
    );

    if (atualizou == true) {
      await _viewModel.carregarReservas();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva atualizada.')));
    }
  }

  void _confirmarExclusao(ReservaDoAluno item) {
    final nome = item.aluno?.nome ?? 'este aluno';
    final data = DateFormat('dd/MM/yyyy').format(item.reserva.dataReserva);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Reserva'),
        content: Text(
          'Remover a reserva de $nome no dia $data? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _viewModel.excluirReserva(item.reserva.id);
            },
            child: const Text(
              'Sim, remover',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPassada = _viewModel.filtroAtual == TipoFiltroReserva.passadas;
    final lista = _viewModel.reservasFiltradas;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reservas',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            FiltroTabs<TipoFiltroReserva>(
              filtroAtual: _viewModel.filtroAtual,
              opcoes: const {
                TipoFiltroReserva.ativas: 'Novas Reservas',
                TipoFiltroReserva.passadas: 'Reservas Antigas',
              },
              onFiltroChanged: _viewModel.alterarFiltro,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _viewModel.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : lista.isEmpty
                  ? EmptyStateView(
                      icon: Icons.event_busy,
                      message: isPassada
                          ? 'Nenhuma reserva antiga encontrada'
                          : 'Nenhuma reserva nova encontrada',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final item = lista[index];
                        return AdminReservaCard(
                          item: item,
                          isPassada: isPassada,
                          onEditar: () => _editar(item),
                          onExcluir: () => _confirmarExclusao(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
