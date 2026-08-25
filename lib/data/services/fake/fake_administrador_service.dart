import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';

class FakeAdministradorService implements AdministradorService {
  final List<Administrador> _administradores = [
    const Administrador(
      id: '1',
      nome: 'Carlos Eduardo',
      email: 'admin@escola.com',
      senha: '123456',
    ),
    const Administrador(
      id: '2',
      nome: 'Fernanda Lima',
      email: 'gestao@escola.com',
      senha: '123456',
    ),
  ];

  @override
  Future<List<Administrador>> buscarTodos() async {
    return List.unmodifiable(_administradores);
  }
}
