import 'package:flutter/material.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/presentation/viewmodels/alunos_viewmodel.dart';
import 'package:agendapf/presentation/views/alunos_detalhes_view.dart';
import 'package:agendapf/presentation/widgets/aluno_list_tile.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';

class AlunosPage extends StatefulWidget {
  final AlunoRepository alunoRepository;
  final AgendaRepository agendaRepository;

  const AlunosPage({
    super.key,
    required this.alunoRepository,
    required this.agendaRepository,
  });

  @override
  State<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  late final AlunosViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AlunosViewModel(alunoRepository: widget.alunoRepository);
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarAlunos();
  }

  void _handleViewModelChange() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _abrirDetalhes(String alunoId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlunoDetalhesPage(
          alunoId: alunoId,
          alunoRepository: widget.alunoRepository,
          agendaRepository: widget.agendaRepository,
        ),
      ),
    );
    // Ao voltar (após edição ou exclusão), recarrega a lista.
    _viewModel.carregarAlunos();
  }

  @override
  Widget build(BuildContext context) {
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
          'Alunos',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : _viewModel.alunos.isEmpty
            ? const EmptyStateView(
                icon: Icons.people_outline,
                message: 'Nenhum aluno cadastrado',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _viewModel.alunos.length,
                itemBuilder: (context, index) {
                  final aluno = _viewModel.alunos[index];
                  return AlunoListTile(
                    aluno: aluno,
                    onTap: () => _abrirDetalhes(aluno.id),
                  );
                },
              ),
      ),
    );
  }
}
