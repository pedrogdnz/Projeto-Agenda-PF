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

//TODO - TEMOS QUE MELHORAR A FORMA COMO VERIFICA A SENHA, ESTÁ EM TEXTO PURO
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

    final aluno = await _alunoService.buscarPorEmailOuMatricula(identificador);
    if (aluno != null) {
      if (aluno.senha == null) {
        throw const CredenciaisInvalidasException();
      }
      if (!_verificadorDeSenha.verificar(senha, aluno.senha!)) {
        throw const CredenciaisInvalidasException();
      }
      return ResultadoLogin.aluno(aluno);
    }

    throw const CredenciaisInvalidasException();
  }

  Future<ResultadoLogin> cadastrarAluno({
    required String nome,
    required String matricula,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final matriculaNormalizada = matricula.trim();

    final adminComEmail = await _administradorService.buscarPorEmail(
      emailNormalizado,
    );
    if (adminComEmail != null) {
      throw const EmailJaCadastradoException();
    }

    final alunoComEmail = await _alunoService.buscarPorEmailOuMatricula(
      emailNormalizado,
    );
    if (alunoComEmail != null) {
      throw const EmailJaCadastradoException();
    }

    final alunoComMatricula = await _alunoService.buscarPorEmailOuMatricula(
      matriculaNormalizada,
    );
    if (alunoComMatricula != null) {
      throw const MatriculaJaCadastradaException();
    }

    final novoAluno = await _alunoService.criar(
      Aluno(
        id: '', // o service (fake ou real) é responsável por gerar o id
        nome: nome.trim(),
        matricula: matriculaNormalizada,
        email: emailNormalizado,
        senha: senha,
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
        id: pendente.uid, // id do documento = uid do Firebase Auth
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
