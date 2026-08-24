import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/auth_data_source.dart.dart';

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
  final AlunoAuthService _alunoService;
  final AdministradorAuthService _administradorService;
  final VerificadorDeSenha _verificadorDeSenha;

  const AuthRepository({
    required AlunoAuthService alunoService,
    required AdministradorAuthService administradorService,
    VerificadorDeSenha verificadorDeSenha = const VerificadorDeSenhaTextoPuro(),
  }) : _alunoService = alunoService,
       _administradorService = administradorService,
       _verificadorDeSenha = verificadorDeSenha;

  Future<ResultadoLogin> autenticar({
    required String identificador,
    required String senha,
  }) async {
    // 1. Tenta autenticar como Administrador primeiro.
    final administrador = await _administradorService.buscarPorEmail(
      identificador,
    );
    if (administrador != null) {
      if (!_verificadorDeSenha.verificar(senha, administrador.senha)) {
        throw const CredenciaisInvalidasException();
      }
      return ResultadoLogin.administrador(administrador);
    }

    // 2. Se não for admin, tenta buscar como Aluno por e-mail ou matrícula.
    final aluno = await _alunoService.buscarPorEmailOuMatricula(identificador);
    if (aluno != null) {
      if (!_verificadorDeSenha.verificar(senha, aluno.senha)) {
        throw const CredenciaisInvalidasException();
      }
      return ResultadoLogin.aluno(aluno);
    }

    throw const CredenciaisInvalidasException();
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
