import 'package:flutter/material.dart';
import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';

class AdministradoresViewModel extends ChangeNotifier {
  final AdministradorRepository _administradorRepository;

  AdministradoresViewModel({
    required AdministradorRepository administradorRepository,
  }) : _administradorRepository = administradorRepository;

  bool _carregando = true;
  List<Administrador> _administradores = [];

  bool get carregando => _carregando;
  List<Administrador> get administradores =>
      List.unmodifiable(_administradores);

  Future<void> carregarAdministradores() async {
    _carregando = true;
    notifyListeners();

    final lista = await _administradorRepository.buscarTodos();
    _administradores = List.of(lista)..sort((a, b) => a.nome.compareTo(b.nome));

    _carregando = false;
    notifyListeners();
  }
}
