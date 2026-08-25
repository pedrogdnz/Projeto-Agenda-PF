import 'package:agendapf/data/models/horario_model.dart';

abstract class HorarioService {
  Future<List<Horario>> buscarTodos();
}