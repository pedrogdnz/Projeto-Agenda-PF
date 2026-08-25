import 'package:agendapf/data/models/administrador_model.dart';

abstract class AdministradorService {
  Future<List<Administrador>> buscarTodos();
  Future<Administrador?> buscarPorEmail(String email);
}