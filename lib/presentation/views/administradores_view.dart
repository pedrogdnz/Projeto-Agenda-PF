import 'package:flutter/material.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';
import 'package:agendapf/presentation/viewmodels/administradores_viewmodel.dart';
import 'package:agendapf/presentation/views/administrador_detalhes_view.dart';
import 'package:agendapf/presentation/widgets/administrador_list_tile.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';

class AdministradoresPage extends StatefulWidget {
  final AdministradorRepository administradorRepository;

  const AdministradoresPage({super.key, required this.administradorRepository});

  @override
  State<AdministradoresPage> createState() => _AdministradoresPageState();
}

class _AdministradoresPageState extends State<AdministradoresPage> {
  late final AdministradoresViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdministradoresViewModel(
      administradorRepository: widget.administradorRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarAdministradores();
  }

  void _handleViewModelChange() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _abrirDetalhes(String administradorId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdministradorDetalhesPage(
          administradorId: administradorId,
          administradorRepository: widget.administradorRepository,
        ),
      ),
    );
    // Ao voltar (após edição ou exclusão), recarrega a lista.
    _viewModel.carregarAdministradores();
  }

  Future<void> _abrirCriacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdministradorDetalhesPage(
          administradorRepository: widget.administradorRepository,
        ),
      ),
    );
    _viewModel.carregarAdministradores();
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
          'Administradores',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _abrirCriacao,
        tooltip: 'Novo administrador',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: _viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : _viewModel.administradores.isEmpty
            ? const EmptyStateView(
                icon: Icons.admin_panel_settings_outlined,
                message: 'Nenhum administrador cadastrado',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _viewModel.administradores.length,
                itemBuilder: (context, index) {
                  final administrador = _viewModel.administradores[index];
                  return AdministradorListTile(
                    administrador: administrador,
                    onTap: () => _abrirDetalhes(administrador.id),
                  );
                },
              ),
      ),
    );
  }
}
