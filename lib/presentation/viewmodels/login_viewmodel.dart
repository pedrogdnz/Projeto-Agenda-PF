import 'package:flutter/material.dart';

/// ViewModel responsável pelo estado e pelas regras de negócio
/// da tela de login (validação de campos e ação de login).
class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

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

  /// Valida o formulário. Retorna `true` se os dados estiverem válidos.
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }
}