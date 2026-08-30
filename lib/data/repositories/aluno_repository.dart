import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/repositories/auth_repository.dart'
    show EmailJaCadastradoException, MatriculaJaCadastradaException;
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

//TODO - aqui é o tigo falando, num é erro não - só avisando que excluir um aluno
// aqui não remove nem bloqueia as reservas já feitas por ele, problema futuro

class AlunoNaoEncontradoException implements Exception {
  final String mensagem;
  const AlunoNaoEncontradoException([this.mensagem = 'Aluno não encontrado.']);

  @override
  String toString() => mensagem;
}

/// Repositório de CRUD de Alunos usado pelo painel do Administrador.
/// Reaproveita as mesmas exceções de conflito de e-mail/matrícula já
/// definidas em [AuthRepository] em vez de duplicar essa validação.
class AlunoRepository {
  final AlunoService _alunoService;
  final AdministradorService _administradorService;

  const AlunoRepository({
    required AlunoService alunoService,
    required AdministradorService administradorService,
  }) : _alunoService = alunoService,
       _administradorService = administradorService;

  AlunoService get alunoService => _alunoService;

  Future<List<Aluno>> buscarTodos() => _alunoService.buscarTodos();

  Future<Aluno?> buscarPorId(String id) => _alunoService.buscarPorId(id);

  /// Atualiza os dados cadastrais do aluno. Se [novaSenha] vier nula ou
  /// vazia, a senha atual é preservada — o administrador nunca visualiza
  /// a senha existente, apenas pode substituí-la por uma nova.
  Future<Aluno> atualizar({
    required String id,
    required String nome,
    required String matricula,
    required String email,
    String? novaSenha,
  }) async {
    final atual = await _alunoService.buscarPorId(id);
    if (atual == null) {
      throw const AlunoNaoEncontradoException();
    }

    final nomeNormalizado = nome.trim();
    final matriculaNormalizada = matricula.trim();
    final emailNormalizado = email.trim().toLowerCase();

    if (emailNormalizado != atual.email.toLowerCase()) {
      final adminComEmail = await _administradorService.buscarPorEmail(
        emailNormalizado,
      );
      if (adminComEmail != null) {
        throw const EmailJaCadastradoException();
      }

      final alunoComEmail = await _alunoService.buscarPorEmailOuMatricula(
        emailNormalizado,
      );
      if (alunoComEmail != null && alunoComEmail.id != id) {
        throw const EmailJaCadastradoException();
      }
    }

    if (matriculaNormalizada != atual.matricula) {
      final alunoComMatricula = await _alunoService.buscarPorEmailOuMatricula(
        matriculaNormalizada,
      );
      if (alunoComMatricula != null && alunoComMatricula.id != id) {
        throw const MatriculaJaCadastradaException();
      }
    }

    final atualizado = atual.copyWith(
      nome: nomeNormalizado,
      matricula: matriculaNormalizada,
      email: emailNormalizado,
      senha: (novaSenha != null && novaSenha.trim().isNotEmpty)
          ? novaSenha.trim()
          : null, // null no copyWith preserva a senha atual
    );

    return _alunoService.atualizar(atualizado);
  }

  Future<void> excluir(String id) => _alunoService.excluir(id);
}
