import 'package:agendapf/data/services/abstract/auth_data_source.dart';

class FakeAuthService implements AuthService {
  @override
  Future<UsuarioGoogle> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UsuarioGoogle(
      uid: 'fake-uid-123',
      nome: 'Aluno Fake',
      email: 'aluno.fake@estudantes.ifpr.edu.br',
    );
  }

  @override
  Future<void> signOut() async {}
}