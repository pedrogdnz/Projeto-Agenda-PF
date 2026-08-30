/// Contrato de autenticação. Não sabe nada sobre Aluno/Administrador —
/// só sabe autenticar e devolver os dados básicos de quem logou.
abstract class AuthService {
  Future<UsuarioGoogle> signInWithGoogle();
  Future<void> signOut();
  Stream<UsuarioGoogle?> get authStateChanges;
}

class UsuarioGoogle {
  final String uid;
  final String nome;
  final String email;

  const UsuarioGoogle({
    required this.uid,
    required this.nome,
    required this.email,
  });
}

class LoginCanceladoException implements Exception {
  final String mensagem;
  const LoginCanceladoException([this.mensagem = 'Login cancelado.']);
  @override
  String toString() => mensagem;
}