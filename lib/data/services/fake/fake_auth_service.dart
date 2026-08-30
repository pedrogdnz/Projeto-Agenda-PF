import 'dart:async';
import 'package:agendapf/data/services/abstract/auth_data_source.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<UsuarioGoogle?>.broadcast();
  UsuarioGoogle? _usuarioAtual;

  @override
  Stream<UsuarioGoogle?> get authStateChanges => _controller.stream;

  @override
  Future<UsuarioGoogle> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _usuarioAtual = const UsuarioGoogle(
      uid: 'fake-uid-123',
      nome: 'Aluno Fake',
      email: 'aluno.fake@estudantes.ifpr.edu.br',
    );
    _controller.add(_usuarioAtual);
    return _usuarioAtual!;
  }

  @override
  Future<void> signOut() async {
    _usuarioAtual = null;
    _controller.add(null);
  }
}