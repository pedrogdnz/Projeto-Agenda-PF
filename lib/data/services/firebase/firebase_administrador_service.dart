import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/administrador_model.dart';
import 'package:agendapf/data/services/abstract/administrador_data_source.dart';

class FirebaseAdministradorService implements AdministradorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('administradores');

  @override
  Future<List<Administrador>> buscarTodos() async {
    final snapshot = await _colecao.get();
    return snapshot.docs
        .map((doc) => Administrador.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<Administrador?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return Administrador.fromMap(doc.data()!);
  }

  @override
  Future<Administrador?> buscarPorEmail(String email) async {
    final snapshot = await _colecao
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Administrador.fromMap(snapshot.docs.first.data());
  }

  Future<List<Administrador>> buscarPorNomeOuEmail(String query) async {
    if (query.trim().isEmpty) return [];

    // Busca por "começa com" no nome — Firestore não tem "contains" nativo.
    // Truque padrão: intervalo entre a query e a query + caractere Unicode alto.
    final porNome = await _colecao
        .orderBy('nome')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    final porEmail = await _colecao
        .where('email', isEqualTo: query.trim())
        .get();

    final resultados = <String, Administrador>{}; // dedup por id
    for (final doc in [...porNome.docs, ...porEmail.docs]) {
      final admin = Administrador.fromMap(doc.data());
      resultados[admin.id] = admin;
    }

    return resultados.values.toList();
  }

  @override
  Future<Administrador> criar(Administrador administrador) async {
    // administrador.id deve ser o uid da conta criada no Firebase Auth.
    // É a existência deste documento que faz a conta ser tratada como admin.
    await _colecao.doc(administrador.id).set(_paraFirestore(administrador));
    return administrador;
  }

  @override
  Future<Administrador> atualizar(Administrador administrador) async {
    await _colecao.doc(administrador.id).update(_paraFirestore(administrador));
    return administrador;
  }

  @override
  Future<void> excluir(String id) async {
    // Remove o perfil de admin (a conta no Firebase Auth continua existindo,
    // mas sem este documento ela deixa de ser reconhecida como administrador).
    await _colecao.doc(id).delete();
  }

  /// Nunca grava a senha no Firestore: quem guarda é o Firebase Auth.
  Map<String, dynamic> _paraFirestore(Administrador administrador) {
    return administrador.toMap()..remove('senha');
  }
}