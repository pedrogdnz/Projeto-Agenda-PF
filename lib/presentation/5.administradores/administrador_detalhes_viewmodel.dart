import 'package:flutter/material.dart';
import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';

class AdministradorDetalhesViewModel extends ChangeNotifier {
  final String? administradorId;
  final AdministradorRepository _administradorRepository;

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  AdministradorDetalhesViewModel({
    this.administradorId,
    required AdministradorRepository administradorRepository,
  }) : _administradorRepository = administradorRepository;

  bool get ehCriacao => administradorId == null;

  bool _carregando = true;
  Administrador? _administrador;

  bool _editando = false;
  bool _salvando = false;
  bool _excluindo = false;
  bool _excluido = false;
  bool _criado = false;
  String? _erro;

  bool get carregando => _carregando;
  Administrador? get administrador => _administrador;
  bool get editando => _editando;
  bool get salvando => _salvando;
  bool get excluindo => _excluindo;
  bool get excluido => _excluido;
  bool get criado => _criado;
  String? get erro => _erro;

  /// Em modo de criação não há nada para buscar: já libera o formulário.
  Future<void> carregar() async {
    if (ehCriacao) {
      _carregando = false;
      _editando = true;
      notifyListeners();
      return;
    }

    _carregando = true;
    notifyListeners();

    _administrador = await _administradorRepository.buscarPorId(
      administradorId!,
    );

    _carregando = false;
    notifyListeners();
  }

  void iniciarEdicao() {
    final atual = _administrador;
    if (atual == null) return;

    nomeController.text = atual.nome;
    emailController.text = atual.email;
    senhaController.clear();

    _editando = true;
    _erro = null;
    notifyListeners();
  }

  void cancelarEdicao() {
    _editando = false;
    _erro = null;
    notifyListeners();
  }

  String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o nome';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    if (!value.contains('@')) return 'E-mail inválido';
    return null;
  }

  /// Na criação a senha é obrigatória; na edição é opcional (só valida se
  /// o administrador digitou algo, para trocar a senha atual).
  String? validateSenha(String? value) {
    if (ehCriacao) {
      if (value == null || value.trim().isEmpty) return 'Informe a senha';
      if (value.trim().length < 6) {
        return 'A senha deve ter pelo menos 6 caracteres';
      }
      return null;
    }

    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 6) {
      return 'A nova senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<bool> salvar() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      if (ehCriacao) {
        await _administradorRepository.criar(
          nome: nomeController.text,
          email: emailController.text,
          senha: senhaController.text,
        );
        _criado = true;
      } else {
        _administrador = await _administradorRepository.atualizar(
          id: administradorId!,
          nome: nomeController.text,
          email: emailController.text,
          novaSenha: senhaController.text,
        );
        _editando = false;
      }
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirAdministrador() async {
    final id = administradorId;
    if (id == null) return false;

    _excluindo = true;
    _erro = null;
    notifyListeners();

    try {
      await _administradorRepository.excluir(id);
      _excluido = true;
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _excluindo = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}
