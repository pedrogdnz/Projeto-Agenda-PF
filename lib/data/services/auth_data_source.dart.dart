import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/models/aluno_model.dart';

abstract class AlunoAuthService {
  Future<Aluno?> buscarPorEmailOuMatricula(String identificador);
}

abstract class AdministradorAuthService {
  Future<Administrador?> buscarPorEmail(String email);
}
