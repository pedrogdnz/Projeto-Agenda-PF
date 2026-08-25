import 'package:agendapf/data/models/aluno_model.dart';

abstract class AlunoService {
  Future<List<Aluno>> buscarTodos();
  Future<Aluno?> buscarPorId(String id);
  Future<Aluno?> buscarPorEmailOuMatricula(String identificador);
  Future<List<Aluno>> buscarPorNomeOuMatricula(String query);
  Future<Aluno> criar(Aluno aluno);
  Future<Aluno> atualizar(Aluno aluno);
  Future<void> excluir(String id);
}