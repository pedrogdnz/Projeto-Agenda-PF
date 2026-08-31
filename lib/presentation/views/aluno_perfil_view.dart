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

  Future<void> _salvar() async {
    final sucesso = await _viewModel.salvar();
    if (!mounted) return;

    final erro = _viewModel.erro;
    if (!sucesso && erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          : _viewModel.aluno == null
          ? const Center(child: Text('Não foi possível carregar seu perfil.'))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meu Perfil',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      isPassword: false,
                      controller: _viewModel.nomeController,
                      label: 'Nome',
                      validator: _viewModel.validateNome,
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      isPassword: false,
                      controller: _viewModel.matriculaController,
                      label: 'Matrícula',
                      keyboardType: TextInputType.number,
                      validator: _viewModel.validateMatricula,
                    ),
                    const SizedBox(height: 20),

                    // E-mail é só leitura — muda-lo exigiria reautenticar
                    // no Firebase Auth, fora do escopo por ora.
                    Text(
                      'E-mail',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _viewModel.email ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.black),
                        onPressed: _viewModel.salvando ? null : _salvar,
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
                                'Salvar alterações',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}