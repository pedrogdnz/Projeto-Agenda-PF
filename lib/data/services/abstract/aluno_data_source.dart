import 'package:agendapf/data/models/aluno_model.dart';

abstract class AlunoService {
  Future<List<Aluno>> buscarTodos();
}
