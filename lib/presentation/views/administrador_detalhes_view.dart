import 'package:flutter/material.dart';
import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';
import 'package:agendapf/presentation/viewmodels/administrador_detalhes_viewmodel.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';
import 'package:agendapf/presentation/widgets/text_field.dart';

class AdministradorDetalhesPage extends StatefulWidget {
  /// Nulo abre a tela em modo de criação de um novo administrador.
  final String? administradorId;
  final AdministradorRepository administradorRepository;

  const AdministradorDetalhesPage({
    super.key,
    this.administradorId,
    required this.administradorRepository,
  });

  @override
  State<AdministradorDetalhesPage> createState() =>
      _AdministradorDetalhesPageState();
}

class _AdministradorDetalhesPageState extends State<AdministradorDetalhesPage> {
  late final AdministradorDetalhesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdministradorDetalhesViewModel(
      administradorId: widget.administradorId,
      administradorRepository: widget.administradorRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregar();
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

    if (_viewModel.excluido || _viewModel.criado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Administrador'),
        content: Text(
          'Tem certeza de que deseja excluir '
          '${_viewModel.administrador?.nome ?? 'este administrador'}? '
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
              await _viewModel.excluirAdministrador();
            },
            child: const Text(
              'Sim, excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final administrador = _viewModel.administrador;
    final ehCriacao = _viewModel.ehCriacao;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          ehCriacao ? 'Novo Administrador' : 'Detalhes do Administrador',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: _viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : (!ehCriacao && administrador == null)
          ? const EmptyStateView(
              icon: Icons.person_off_outlined,
              message: 'Administrador não encontrado',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!ehCriacao) ...[
                      _buildCabecalho(administrador!),
                      const SizedBox(height: 20),
                    ],
                    _viewModel.editando
                        ? _buildFormulario()
                        : _buildInformacoes(administrador!),
                    if (!ehCriacao && !_viewModel.editando) ...[
                      const SizedBox(height: 28),
                      _buildBotoesAcao(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCabecalho(Administrador administrador) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          child: Text(
            administrador.nome.isNotEmpty
                ? administrador.nome[0].toUpperCase()
                : '?',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            administrador.nome,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoes(Administrador administrador) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLinha(label: 'Nome', valor: administrador.nome),
          const Divider(height: 20),
          _InfoLinha(label: 'E-mail', valor: administrador.email),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.nomeController,
            label: 'Nome',
            validator: _viewModel.validateNome,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.emailController,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            validator: _viewModel.validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            requiredField: _viewModel.ehCriacao,
            isPassword: true,
            controller: _viewModel.senhaController,
            label: _viewModel.ehCriacao ? 'Senha' : 'Nova senha (opcional)',
            validator: _viewModel.validateSenha,
          ),
          if (!_viewModel.ehCriacao) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Deixe em branco para manter a senha atual.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (!_viewModel.ehCriacao) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _viewModel.salvando
                        ? null
                        : _viewModel.cancelarEdicao,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _viewModel.salvando ? null : _viewModel.salvar,
                  child: _viewModel.salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _viewModel.ehCriacao ? 'Cadastrar' : 'Salvar',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _viewModel.excluindo ? null : _confirmarExclusao,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _viewModel.excluindo
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text('Excluir'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _viewModel.excluindo ? null : _viewModel.iniciarEdicao,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text('Editar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final String label;
  final String valor;

  const _InfoLinha({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
