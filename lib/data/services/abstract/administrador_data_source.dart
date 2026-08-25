import 'package:agendapf/data/models/administrador_model.dart';

abstract class AdministradorService {
  Future<List<Administrador>> buscarTodos();
  Future<Administrador?> buscarPorId(String id);
  Future<Administrador?> buscarPorEmail(String email);
  Future<Administrador> criar(Administrador administrador);
  Future<Administrador> atualizar(Administrador administrador);
  Future<void> excluir(String id);
}