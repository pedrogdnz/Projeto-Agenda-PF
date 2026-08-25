import 'package:agendapf/data/models/horario_model.dart';

abstract class HorarioService {
  Future<List<Horario>> buscarTodos();
  Future<Horario?> buscarPorId(String id);
  Future<Horario> criar(Horario horario);
  Future<Horario> atualizar(Horario horario);
  Future<void> excluir(String id);
}
