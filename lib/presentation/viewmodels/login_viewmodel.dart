import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/data/services/fake/fake_administrador_service.dart';
import 'package:agendapf/data/services/firebase/firebase_aluno_service.dart';
import 'package:agendapf/data/services/firebase/firebase_auth_service.dart';
import 'package:flutter/material.dart';

/// Controla qual formulário está sendo exibido: Login ou Cadastro (RF01).
enum ModoFormulario { login, cadastro }

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final matriculaGoogleFormKey = GlobalKey<FormState>();

  // Campos comuns a Login e Cadastro.
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  // Campos exclusivos do Cadastro (RF01).
  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();

  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
    : _authRepository =
          authRepository ??
          AuthRepository(
            authService: FirebaseAuthService(),
            alunoService: FirebaseAlunoService(),
            administradorService: FakeAdministradorService(),
          );

  ModoFormulario _modo = ModoFormulario.login;
  bool _carregando = false;
  String? _erro;
  ResultadoLogin? _resultado;
  GoogleContaPendente? _contaGooglePendente;

  ModoFormulario get modo => _modo;
  bool get ehCadastro => _modo == ModoFormulario.cadastro;
  bool get carregando => _carregando;
  String? get erro => _erro;
  GoogleContaPendente? get contaGooglePendente => _contaGooglePendente;
  bool get aguardandoMatriculaGoogle => _contaGooglePendente != null;

  /// Resultado do login (seja por autenticação direta, seja pelo login
  /// automático que ocorre logo após um cadastro bem-sucedido). A View usa
  /// esse valor, e apenas ele, para decidir para onde redirecionar o
  /// usuário — o mesmo fluxo serve tanto para Login quanto para Cadastro.
  ResultadoLogin? get resultado => _resultado;

  // dentro de LoginViewModel
AuthRepository get authRepository => _authRepository; // NOVO

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    nomeController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  /// Alterna entre os formulários de Login e Cadastro, limpando erros e
  /// campos que não fazem sentido no outro modo.
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

  bool validate() => formKey.currentState?.validate() ?? false;

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

  /// Cadastra um novo Aluno (RF01) e já autentica automaticamente,
  /// preenchendo [resultado] da mesma forma que [autenticar] faz.
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

  /// Ponto único de entrada para a View: dispara Login ou Cadastro
  /// dependendo do [modo] atual.
  Future<bool> enviar() {
    return ehCadastro ? cadastrar() : autenticar();
  }

  Future<bool> entrarComGoogle() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      final resultadoGoogle = await _authRepository.entrarComGoogle();
      if (resultadoGoogle.precisaCompletarCadastro) {
        _contaGooglePendente = resultadoGoogle.pendente;
      } else {
        _resultado = resultadoGoogle.resultado;
      }
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// NOVO — completa o cadastro (matrícula) no 1º login via Google.
  Future<bool> confirmarMatriculaGoogle() async {
    final valido = matriculaGoogleFormKey.currentState?.validate() ?? false;
    if (!valido) return false;

    final pendente = _contaGooglePendente;
    if (pendente == null) return false;

    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _resultado = await _authRepository.completarCadastroAluno(
        pendente: pendente,
        matricula: matriculaController.text,
      );
      _contaGooglePendente = null;
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// NOVO — volta pro formulário normal cancelando o cadastro via Google.
  void cancelarCadastroGoogle() {
    _contaGooglePendente = null;
    _erro = null;
    matriculaController.clear();
    notifyListeners();
  }
}

