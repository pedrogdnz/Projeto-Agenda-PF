import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/auth_repository.dart'
    show EmailJaCadastradoException;
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

class AdministradorNaoEncontradoException implements Exception {
  final String mensagem;
  const AdministradorNaoEncontradoException([
    this.mensagem = 'Administrador não encontrado.',
  ]);

  @override
  String toString() => mensagem;
}

class UltimoAdministradorException implements Exception {
  final String mensagem;
  const UltimoAdministradorException([
    this.mensagem = 'Não é possível excluir o único administrador restante.',
  ]);

  @override
  String toString() => mensagem;
}
class AdministradorRepository {
  final AdministradorService _administradorService;
  final AlunoService _alunoService;

  const AdministradorRepository({
    required AdministradorService administradorService,
    required AlunoService alunoService,
  }) : _administradorService = administradorService,
       _alunoService = alunoService;

  AdministradorService get administradorService => _administradorService;

  Future<List<Administrador>> buscarTodos() =>
      _administradorService.buscarTodos();

  Future<Administrador?> buscarPorId(String id) =>
      _administradorService.buscarPorId(id);

  Future<Administrador> criar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    await _garantirEmailDisponivel(emailNormalizado);

    return _administradorService.criar(
      Administrador(
        id: '', 
        nome: nome.trim(),
        email: emailNormalizado,
        senha: senha,
      ),
    );
  }

  /// Atualiza os dados cadastrais do administrador. Se [novaSenha] vier
  /// nula ou vazia, a senha atual é preservada — mesmo comportamento do
  /// AlunoRepository.atualizar.
  Future<Administrador> atualizar({
    required String id,
    required String nome,
    required String email,
    String? novaSenha,
  }) async {
    final atual = await _administradorService.buscarPorId(id);
    if (atual == null) {
      throw const AdministradorNaoEncontradoException();
    }

    final nomeNormalizado = nome.trim();
    final emailNormalizado = email.trim().toLowerCase();

    if (emailNormalizado != atual.email.toLowerCase()) {
      await _garantirEmailDisponivel(emailNormalizado, ignorarId: id);
    }

    final atualizado = atual.copyWith(
      nome: nomeNormalizado,
      email: emailNormalizado,
      senha: (novaSenha != null && novaSenha.trim().isNotEmpty)
          ? novaSenha.trim()
          : null,
    );

    return _administradorService.atualizar(atualizado);
  }

  Future<void> excluir(String id) async {
    final todos = await _administradorService.buscarTodos();
    if (todos.length <= 1) {
      throw const UltimoAdministradorException();
    }

    await _administradorService.excluir(id);
  }

  Future<void> _garantirEmailDisponivel(
    String emailNormalizado, {
    String? ignorarId,
  }) async {
    final adminComEmail = await _administradorService.buscarPorEmail(
      emailNormalizado,
    );
    if (adminComEmail != null && adminComEmail.id != ignorarId) {
      throw const EmailJaCadastradoException();
    }

    final alunoComEmail = await _alunoService.buscarPorEmailOuMatricula(
      emailNormalizado,
    );
    if (alunoComEmail != null) {
      throw const EmailJaCadastradoException();
    }
  }
}
