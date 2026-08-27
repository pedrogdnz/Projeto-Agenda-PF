import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

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
  final AlunoService _alunoService;
  final AdministradorService _administradorService;
  final VerificadorDeSenha _verificadorDeSenha;

  const AuthRepository({
    required AlunoService alunoService,
    required AdministradorService administradorService,
    VerificadorDeSenha verificadorDeSenha = const VerificadorDeSenhaTextoPuro(),
  }) : _alunoService = alunoService,
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
      if (!_verificadorDeSenha.verificar(senha, aluno.senha)) {
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

  void garantirAcessoAdministrativo(TipoUsuario tipo) {
    if (tipo != TipoUsuario.administrador) {
      throw const AcessoNegadoException();
    }
  }

  bool possuiAcessoAdministrativo(TipoUsuario tipo) {
    return tipo == TipoUsuario.administrador;
  }
}
