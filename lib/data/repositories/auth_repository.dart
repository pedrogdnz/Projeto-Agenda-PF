import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';
import 'package:agendapf/data/services/abstract/auth_data_source.dart';

enum TipoUsuario { aluno, administrador }

class CredenciaisInvalidasException implements Exception {
  final String mensagem;
  const CredenciaisInvalidasException([
    this.mensagem = 'E-mail/matrícula ou senha inválidos.',
  ]);

  @override
  String toString() => mensagem;
}

class AcessoNegadoException implements Exception {
  final String mensagem;
  const AcessoNegadoException([
    this.mensagem = 'Você não tem permissão para acessar este recurso.',
  ]);

  @override
  String toString() => mensagem;
}

class EmailJaCadastradoException implements Exception {
  final String mensagem;
  const EmailJaCadastradoException([
    this.mensagem = 'Este e-mail já está cadastrado.',
  ]);

  @override
  String toString() => mensagem;
}

class MatriculaJaCadastradaException implements Exception {
  final String mensagem;
  const MatriculaJaCadastradaException([
    this.mensagem = 'Esta matrícula já está cadastrada.',
  ]);

  @override
  String toString() => mensagem;
}

class DominioNaoPermitidoException implements Exception {
  final String mensagem;
  const DominioNaoPermitidoException([
    this.mensagem = 'Use seu e-mail institucional (@estudantes.ifpr.edu.br).',
  ]);
  @override
  String toString() => mensagem;
}

class ResultadoLogin {
  final TipoUsuario tipo;
  final Aluno? aluno;
  final Administrador? administrador;

  const ResultadoLogin.aluno(Aluno this.aluno)
    : tipo = TipoUsuario.aluno,
      administrador = null;

  const ResultadoLogin.administrador(Administrador this.administrador)
    : tipo = TipoUsuario.administrador,
      aluno = null;

  bool get ehAdministrador => tipo == TipoUsuario.administrador;
  bool get ehAluno => tipo == TipoUsuario.aluno;
}

/// Dados mínimos do Google enquanto o cadastro do aluno ainda não foi
/// concluído (falta a matrícula).
class GoogleContaPendente {
  final String uid;
  final String nome;
  final String email;

  const GoogleContaPendente({
    required this.uid,
    required this.nome,
    required this.email,
  });
}

/// Resultado do login via Google: ou já terminou (aluno já existia), ou
/// falta completar o cadastro com a matrícula.
class GoogleLoginResult {
  final ResultadoLogin? resultado;
  final GoogleContaPendente? pendente;

  const GoogleLoginResult.completo(ResultadoLogin this.resultado)
    : pendente = null;
  const GoogleLoginResult.pendente(GoogleContaPendente this.pendente)
    : resultado = null;

  bool get precisaCompletarCadastro => pendente != null;
}

//TODO - administrador continua com verificação manual por enquanto (fora de escopo)
abstract class VerificadorDeSenha {
  bool verificar(String senhaDigitada, String senhaArmazenada);
}

class VerificadorDeSenhaTextoPuro implements VerificadorDeSenha {
  const VerificadorDeSenhaTextoPuro();

  @override
  bool verificar(String senhaDigitada, String senhaArmazenada) {
    return senhaDigitada == senhaArmazenada;
  }
}

class AuthRepository {
  final AuthService _authService;
  final AlunoService _alunoService;
  final AdministradorService _administradorService;
  final VerificadorDeSenha _verificadorDeSenha;

  const AuthRepository({
    required AuthService authService,
    required AlunoService alunoService,
    required AdministradorService administradorService,
    VerificadorDeSenha verificadorDeSenha = const VerificadorDeSenhaTextoPuro(),
  }) : _authService = authService,
       _alunoService = alunoService,
       _administradorService = administradorService,
       _verificadorDeSenha = verificadorDeSenha;

  /// Login por e-mail/senha. Administrador continua com verificação manual;
  /// Aluno autentica de verdade no Firebase Auth antes de tocar o Firestore.
  Future<ResultadoLogin> autenticar({
    required String identificador,
    required String senha,
  }) async {
    final administrador = await _administradorService.buscarPorEmail(
      identificador,
    );
    if (administrador != null) {
      if (!_verificadorDeSenha.verificar(senha, administrador.senha)) {
        throw const CredenciaisInvalidasException();
      }
      return ResultadoLogin.administrador(administrador);
    }

    final usuarioAuth = await _authService.signInComEmail(
      email: identificador.trim(),
      senha: senha,
    );

    final aluno = await _alunoService.buscarPorId(usuarioAuth.uid);
    if (aluno == null) {
      throw const CredenciaisInvalidasException();
    }

    return ResultadoLogin.aluno(aluno);
  }

  /// Cadastra um novo Aluno via e-mail/senha, autenticando de verdade
  /// no Firebase Auth antes de gravar o perfil no Firestore.
  Future<ResultadoLogin> cadastrarAluno({
    required String nome,
    required String matricula,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final matriculaNormalizada = matricula.trim();

    final usuarioAuth = await _authService.cadastrarComEmail(
      email: emailNormalizado,
      senha: senha,
    );

    final alunoComMatricula = await _alunoService.buscarPorEmailOuMatricula(
      matriculaNormalizada,
    );
    if (alunoComMatricula != null) {
      await _authService.excluirContaAtual();
      throw const MatriculaJaCadastradaException();
    }

    final novoAluno = await _alunoService.criar(
      Aluno(
        id: usuarioAuth.uid,
        nome: nome.trim(),
        matricula: matriculaNormalizada,
        email: emailNormalizado,
        senha: null,
        criadoEm: DateTime.now(),
      ),
    );

    return ResultadoLogin.aluno(novoAluno);
  }

  Future<GoogleLoginResult> entrarComGoogle() async {
    final usuarioGoogle = await _authService.signInWithGoogle();

    if (!usuarioGoogle.email.endsWith('@estudantes.ifpr.edu.br')) {
      await _authService.signOut();
      throw const DominioNaoPermitidoException();
    }

    final aluno = await _alunoService.buscarPorId(usuarioGoogle.uid);
    if (aluno != null) {
      return GoogleLoginResult.completo(ResultadoLogin.aluno(aluno));
    }

    return GoogleLoginResult.pendente(
      GoogleContaPendente(
        uid: usuarioGoogle.uid,
        nome: usuarioGoogle.nome,
        email: usuarioGoogle.email,
      ),
    );
  }

  Future<ResultadoLogin> completarCadastroAluno({
    required GoogleContaPendente pendente,
    required String matricula,
  }) async {
    final matriculaNormalizada = matricula.trim();

    final existente = await _alunoService.buscarPorEmailOuMatricula(
      matriculaNormalizada,
    );
    if (existente != null) {
      throw const MatriculaJaCadastradaException();
    }

    final novoAluno = await _alunoService.criar(
      Aluno(
        id: pendente.uid,
        nome: pendente.nome,
        matricula: matriculaNormalizada,
        email: pendente.email,
        senha: null,
        criadoEm: DateTime.now(),
      ),
    );

    return ResultadoLogin.aluno(novoAluno);
  }

  Stream<Aluno?> get alunoAutenticado {
    return _authService.authStateChanges.asyncMap((usuarioGoogle) async {
      if (usuarioGoogle == null) return null;
      return _alunoService.buscarPorId(usuarioGoogle.uid);
    });
  }

  Future<void> logout() => _authService.signOut();

  void garantirAcessoAdministrativo(TipoUsuario tipo) {
    if (tipo != TipoUsuario.administrador) {
      throw const AcessoNegadoException();
    }
  }

  bool possuiAcessoAdministrativo(TipoUsuario tipo) {
    return tipo == TipoUsuario.administrador;
  }
}