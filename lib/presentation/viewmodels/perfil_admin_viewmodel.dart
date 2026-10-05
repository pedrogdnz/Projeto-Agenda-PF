import 'package:flutter/material.dart';

import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';
import 'package:agendapf/data/repositories/auth_repository.dart';

class PerfilAdminViewModel extends ChangeNotifier {
  final String adminId;
  final AdministradorRepository administradorRepository;
  final AuthRepository authRepository;

  PerfilAdminViewModel({
    required this.adminId,
    required this.administradorRepository,
    required this.authRepository,
  });

  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  Administrador? _admin;

  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;
  Administrador? get admin => _admin;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final administrador =
          await administradorRepository.buscarPorId(adminId);

      _admin = administrador;

      if (administrador != null) {
        nomeController.text = administrador.nome;
        emailController.text = administrador.email;
      }
    } catch (e) {
      _erro = 'Não foi possível carregar seu perfil.';
    }

    _carregando = false;
    notifyListeners();
  }

  String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome.';
    }

    if (value.trim().length < 3) {
      return 'Nome muito curto.';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }

    final email = value.trim();

    final emailValido = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValido) {
      return 'Informe um e-mail válido.';
    }

    return null;
  }

  Future<bool> salvar() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (_admin == null) {
      _erro = 'Administrador não encontrado.';
      notifyListeners();
      return false;
    }

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      final atualizado = await administradorRepository.atualizar(
        id: adminId,
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
      );

      _admin = atualizado;

      nomeController.text = atualizado.nome;
      emailController.text = atualizado.email;

      _salvando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _erro = e.toString();

      _salvando = false;
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    super.dispose();
  }
}