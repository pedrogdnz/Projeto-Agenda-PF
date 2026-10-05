import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/repositories/auth_repository.dart'
    show EmailJaCadastradoException;
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';
import 'package:agendapf/data/services/abstract/auth_data_source.dart';

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
  final AuthService _authService; // NOVO

  const AdministradorRepository({
    required AdministradorService administradorService,
    required AlunoService alunoService,
    required AuthService authService, // NOVO
  }) : _administradorService = administradorService,
       _alunoService = alunoService,
       _authService = authService;

  AdministradorService get administradorService => _administradorService;

  Future<List<Administrador>> buscarTodos() => _administradorService.buscarTodos();

  Future<Administrador?> buscarPorId(String id) => _administradorService.buscarPorId(id);

  /// Cria a conta no Firebase Auth e o perfil no Firestore.
  /// ATENÇÃO: criar um usuário via client SDK autentica automaticamente
  /// como ele — isso desloga o admin que estava logado. Resolver isso
  /// exige uma segunda instância do FirebaseApp (fora do escopo por ora).
  Future<Administrador> criar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    await _garantirEmailDisponivel(emailNormalizado);

    final usuarioAuth = await _authService.cadastrarComEmail(
      email: emailNormalizado,
      senha: senha,
    );

    return _administradorService.criar(
      Administrador(
        id: usuarioAuth.uid,
        nome: nome.trim(),
        email: emailNormalizado,
        senha: null,
      ),
    );
  }

  /// Atualiza nome/e-mail. Trocar senha exigiria reautenticação no Firebase
  /// Auth (fora do escopo por ora) — [novaSenha] é ignorado.
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

    final emailNormalizado = email.trim().toLowerCase();

    if (emailNormalizado != atual.email.toLowerCase()) {
      await _garantirEmailDisponivel(emailNormalizado, ignorarId: id);
    }

    final atualizado = atual.copyWith(
      nome: nome.trim(),
      email: emailNormalizado,
    );

    return _administradorService.atualizar(atualizado);
  }

  Future<void> excluir(String id) async {
    final todos = await _administradorService.buscarTodos();
    if (todos.length <= 1) {
      throw const UltimoAdministradorException();
    }
    // Remove só o perfil no Firestore. A conta no Firebase Auth continua
    // existindo (apagar a conta de outro usuário exige Admin SDK/backend).
    await _administradorService.excluir(id);
  }

  Future<void> _garantirEmailDisponivel(
    String emailNormalizado, {
    String? ignorarId,
  }) async {
    final adminComEmail = await _administradorService.buscarPorEmail(emailNormalizado);
    if (adminComEmail != null && adminComEmail.id != ignorarId) {
      throw const EmailJaCadastradoException();
    }

    final alunoComEmail = await _alunoService.buscarPorEmailOuMatricula(emailNormalizado);
    if (alunoComEmail != null) {
      throw const EmailJaCadastradoException();
    }
  }
}