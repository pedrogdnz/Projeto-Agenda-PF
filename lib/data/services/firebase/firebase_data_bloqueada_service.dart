import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/data_bloqueada_model.dart';
import 'package:agendapf/data/services/abstract/data_bloqueada_source.dart';

class FirebaseDataBloqueadaService implements DataBloqueadaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('datas_bloqueadas');

  @override
  Future<List<DataBloqueada>> buscarTodas() async {
    final snapshot = await _colecao.get();
    return snapshot.docs.map((doc) => DataBloqueada.fromMap(doc.data())).toList();
  }

  @override
  Future<DataBloqueada?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return DataBloqueada.fromMap(doc.data()!);
  }

  @override
  Future<DataBloqueada> criar(DataBloqueada dataBloqueada) async {
    final docRef = dataBloqueada.id.isEmpty ? _colecao.doc() : _colecao.doc(dataBloqueada.id);
    final comId = dataBloqueada.id.isEmpty ? dataBloqueada.copyWith(id: docRef.id) : dataBloqueada;
    await docRef.set(comId.toMap());
    return comId;
  }

  @override
  Future<DataBloqueada> atualizar(DataBloqueada dataBloqueada) async {
    await _colecao.doc(dataBloqueada.id).update(dataBloqueada.toMap());
    return dataBloqueada;
  }

  @override
  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}