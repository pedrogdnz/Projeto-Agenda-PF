import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/data/services/fake/fake_administrador_service.dart';
import 'package:agendapf/data/services/fake/fake_aluno_service.dart';
import 'package:flutter/material.dart';

/// Controla qual formulário está sendo exibido: Login ou Cadastro (RF01).
enum ModoFormulario { login, cadastro }

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Campos comuns a Login e Cadastro.
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  // Campos exclusivos do Cadastro.
  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();

  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
    : _authRepository =
          authRepository ??
          AuthRepository(
            alunoService: FakeAlunoService(),
            administradorService: FakeAdministradorService(),
          );

  ModoFormulario _modo = ModoFormulario.login;
  bool _carregando = false;
  String? _erro;
  ResultadoLogin? _resultado;

  ModoFormulario get modo => _modo;
  bool get ehCadastro => _modo == ModoFormulario.cadastro;
  bool get carregando => _carregando;
  String? get erro => _erro;

  ResultadoLogin? get resultado => _resultado;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  void alternarModo() {
    _modo = _modo == ModoFormulario.login
        ? ModoFormulario.cadastro
        : ModoFormulario.login;
    _erro = null;
    formKey.currentState?.reset();
    notifyListeners();
  }

  String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome';
    }
    return null;
  }

  String? validateMatricula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe sua matrícula';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail';
    }

    if (!value.contains('@')) {
      return 'E-mail inválido';
    }

    return null;
  }

  String? validateSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Autentica um Aluno ou Administrador existente (Login).
  Future<bool> autenticar() async {
    if (!validate()) return false;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _resultado = await _authRepository.autenticar(
        identificador: emailController.text.trim(),
        senha: senhaController.text,
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar() async {
    if (!validate()) return false;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _resultado = await _authRepository.cadastrarAluno(
        nome: nomeController.text,
        matricula: matriculaController.text,
        email: emailController.text,
        senha: senhaController.text,
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> enviar() {
    return ehCadastro ? cadastrar() : autenticar();
  }
}
