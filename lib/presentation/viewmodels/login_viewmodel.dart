import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';
import 'package:agendapf/data/services/fake/fake_administrador_service.dart';
import 'package:agendapf/data/services/fake/fake_aluno_service.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
   :_authRepository =
    authRepository ??
    AuthRepository(
      alunoService: FakeAlunoService(),
      administradorService: FakeAdministradorService(),
    );
    
  bool _carregando = false;
  String? _erro;
  ResultadoLogin? _resultado;

  bool get carregando => _carregando;
  String? get erro => _erro;
  ResultadoLogin? get resultado => _resultado;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
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

}
