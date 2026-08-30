import 'package:flutter/material.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';

class AlunosViewModel extends ChangeNotifier {
  final AlunoRepository _alunoRepository;

  AlunosViewModel({required AlunoRepository alunoRepository})
    : _alunoRepository = alunoRepository;

  bool _carregando = true;
  List<Aluno> _alunos = [];

  bool get carregando => _carregando;
  List<Aluno> get alunos => List.unmodifiable(_alunos);

  Future<void> carregarAlunos() async {
    _carregando = true;
    notifyListeners();

    final lista = await _alunoRepository.buscarTodos();
    _alunos = List.of(lista)..sort((a, b) => a.nome.compareTo(b.nome));

    _carregando = false;
    notifyListeners();
  }
}
