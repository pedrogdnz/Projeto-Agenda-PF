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

  @override
  Future<Administrador?> buscarPorId(String id) async {
    for (final admin in _administradores) {
      if (admin.id == id) return admin;
    }
    return null;
  }

  @override
  Future<Administrador?> buscarPorEmail(String email) async {
    final query = email.trim().toLowerCase();

    for (final admin in _administradores) {
      if (admin.email.toLowerCase() == query) {
        return admin;
      }
    }
    return null;
  }

  @override
  Future<Administrador> criar(Administrador administrador) async {
    final novoAdmin = administrador.copyWith(id: _gerarProximoId());
    _administradores.add(novoAdmin);
    return novoAdmin;
  }

  @override
  Future<Administrador> atualizar(Administrador administrador) async {
    final index = _administradores.indexWhere((a) => a.id == administrador.id);
    if (index == -1) {
      throw StateError(
        'Administrador com id ${administrador.id} não encontrado.',
      );
    }
    _administradores[index] = administrador;
    return administrador;
  }

  @override
  Future<void> excluir(String id) async {
    _administradores.removeWhere((admin) => admin.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _administradores.fold<int>(
      0,
      (max, a) => int.tryParse(a.id) != null && int.parse(a.id) > max
          ? int.parse(a.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
