import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

class FirebaseAlunoService implements AlunoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('alunos');

  @override
  Future<List<Aluno>> buscarTodos() async {
    final snapshot = await _colecao.get();
    return snapshot.docs.map((doc) => Aluno.fromMap(doc.data())).toList();
  }

  @override
  Future<Aluno?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return Aluno.fromMap(doc.data()!);
  }

  @override
  Future<Aluno?> buscarPorEmailOuMatricula(String identificador) async {
    // Firestore não tem "OR" nativo simples entre campos diferentes,
    // então fazemos duas queries e pegamos a primeira que encontrar.
    final porEmail = await _colecao
        .where('email', isEqualTo: identificador)
        .limit(1)
        .get();
    if (porEmail.docs.isNotEmpty) {
      return Aluno.fromMap(porEmail.docs.first.data());
    }

    final porMatricula = await _colecao
        .where('matricula', isEqualTo: identificador)
        .limit(1)
        .get();
    if (porMatricula.docs.isNotEmpty) {
      return Aluno.fromMap(porMatricula.docs.first.data());
    }

    return null;
  }

  @override
  Future<List<Aluno>> buscarPorNomeOuMatricula(String query) async {
    if (query.trim().isEmpty) return [];

    // Busca por "começa com" no nome — Firestore não tem "contains" nativo.
    // Truque padrão: intervalo entre a query e a query + caractere Unicode alto.
    final porNome = await _colecao
        .orderBy('nome')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();

    final porMatricula = await _colecao
        .where('matricula', isEqualTo: query.trim())
        .get();

    final resultados = <String, Aluno>{}; // dedup por id
    for (final doc in [...porNome.docs, ...porMatricula.docs]) {
      final aluno = Aluno.fromMap(doc.data());
      resultados[aluno.id] = aluno;
    }

    return resultados.values.toList();
  }

  @override
  Future<Aluno> criar(Aluno aluno) async {
    // aluno.id já vem preenchido com o uid do Firebase Auth
    // (definido no AuthRepository.completarCadastroAluno).
    await _colecao.doc(aluno.id).set(aluno.toMap());
    return aluno;
  }

  @override
  Future<Aluno> atualizar(Aluno aluno) async {
    await _colecao.doc(aluno.id).update(aluno.toMap());
    return aluno;
  }

  @override
  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}