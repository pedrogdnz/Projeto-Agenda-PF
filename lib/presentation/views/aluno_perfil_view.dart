import 'package:flutter/material.dart';
import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/presentation/viewmodels/perfil_aluno_viewmodel.dart';
import 'package:agendapf/presentation/views/login_view.dart';
import 'package:agendapf/presentation/widgets/text_field.dart';

class AlunoPerfil extends StatefulWidget {
  final String alunoId;
  final AuthRepository authRepository;

  const AlunoPerfil({
    super.key,
    required this.alunoId,
    required this.authRepository,
  });

  @override
  State<AlunoPerfil> createState() => _AlunoPerfilState();
}

class _AlunoPerfilState extends State<AlunoPerfil> {
  late final PerfilAlunoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PerfilAlunoViewModel(
      alunoId: widget.alunoId,
      authRepository: widget.authRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregar();
  }

  void _handleViewModelChange() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmarLogout() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza de que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    await _signout();
  }

  Future<void> _signout() async {
    await _viewModel.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _editarCampo({
    required String titulo,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // permite o sheet crescer acima do teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Reflete o estado de "salvando" do ViewModel dentro do próprio
        // sheet, sem precisar de outro StatefulWidget.
        return AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return Padding(
              // Empurra o conteúdo para cima quando o teclado abre.
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _viewModel.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar $titulo',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      requiredField: true,
                      isPassword: false,
                      controller: controller,
                      label: titulo,
                      keyboardType: keyboardType,
                      validator: validator,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.black),
                        onPressed: _viewModel.salvando
                            ? null
                            : () => _salvarESairDoSheet(ctx),
                        child: _viewModel.salvando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _salvarESairDoSheet(BuildContext sheetContext) async {
    final sucesso = await _viewModel.salvar();
    if (!mounted) return;

    if (sucesso) {
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
      return;
    }

    final erro = _viewModel.erro;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final aluno = _viewModel.aluno;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 233, 233, 233),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 233, 233, 233),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromARGB(255, 13, 13, 13),
            size: 20,
          ),
        ),
        actions: [
          IconButton(onPressed: _confirmarLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : aluno == null
          ? const Center(child: Text('Não foi possível carregar seu perfil.'))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${aluno.nome}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: _iconeCampo(Icons.badge_outlined),
                          title: const Text('Nome', style: TextStyle(fontSize: 12)),
                          subtitle: Text(aluno.nome, style: const TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => _editarCampo(
                            titulo: 'Nome',
                            controller: _viewModel.nomeController,
                            validator: _viewModel.validateNome,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        ListTile(
                          leading: _iconeCampo(Icons.numbers),
                          title: const Text('Matrícula', style: TextStyle(fontSize: 12)),
                          subtitle: Text(aluno.matricula, style: const TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => _editarCampo(
                            titulo: 'Matrícula',
                            controller: _viewModel.matriculaController,
                            validator: _viewModel.validateMatricula,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        ListTile(
                          leading: _iconeCampo(Icons.mail_outline),
                          title: const Text('E-mail', style: TextStyle(fontSize: 12)),
                          subtitle: Text(aluno.email, style: const TextStyle(fontSize: 14)),

                        ),
                        const ListTile(
                          leading: null,
                          title: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _iconeCampo(IconData icone) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 215, 213, 213),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Icon(icone),
    );
  }
}