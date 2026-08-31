/// Contrato de autenticação. Não sabe nada sobre Aluno/Administrador —
/// só sabe autenticar e devolver os dados básicos de quem logou.
abstract class AuthService {
  Future<UsuarioGoogle> signInWithGoogle();

  Future<UsuarioGoogle> signInComEmail({
    required String email,
    required String senha,
  });

  Future<UsuarioGoogle> cadastrarComEmail({
    required String email,
    required String senha,
  });

  /// Desfaz um cadastro no meio do caminho (ex: matrícula duplicada
  /// depois que a conta de autenticação já foi criada).
  Future<void> excluirContaAtual();

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

class CredenciaisInvalidasAuthException implements Exception {
  final String mensagem;
  const CredenciaisInvalidasAuthException([
    this.mensagem = 'E-mail ou senha inválidos.',
  ]);
  @override
  String toString() => mensagem;
}

class EmailJaCadastradoAuthException implements Exception {
  final String mensagem;
  const EmailJaCadastradoAuthException([
    this.mensagem = 'Este e-mail já está cadastrado.',
  ]);
  @override
  String toString() => mensagem;
}

class SenhaFracaException implements Exception {
  final String mensagem;
  const SenhaFracaException([
    this.mensagem = 'A senha é muito fraca. Use pelo menos 6 caracteres.',
  ]);
  @override
  String toString() => mensagem;
}