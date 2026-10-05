import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/services/abstract/disponibilidade_padrao_data_source.dart';

class FirebaseDisponibilidadePadraoService implements DisponibilidadePadraoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('disponibilidade_padrao');

  @override
  Future<List<DisponibilidadePadrao>> buscarTodas() async {
    final snapshot = await _colecao.get();
    return snapshot.docs.map((doc) => DisponibilidadePadrao.fromMap(doc.data())).toList();
  }

  @override
  Future<DisponibilidadePadrao?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return DisponibilidadePadrao.fromMap(doc.data()!);
  }

  @override
  Future<DisponibilidadePadrao?> buscarPorDia(DiaSemana diaSemana) async {
    final snapshot = await _colecao
        .where('diaSemana', isEqualTo: diaSemana.name)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return DisponibilidadePadrao.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<DisponibilidadePadrao> criar(DisponibilidadePadrao disponibilidade) async {
    final docRef = disponibilidade.id.isEmpty ? _colecao.doc() : _colecao.doc(disponibilidade.id);
    final comId = disponibilidade.id.isEmpty
        ? disponibilidade.copyWith(id: docRef.id)
        : disponibilidade;
    await docRef.set(comId.toMap());
    return comId;
  }

  @override
  Future<DisponibilidadePadrao> atualizar(DisponibilidadePadrao disponibilidade) async {
    await _colecao.doc(disponibilidade.id).update(disponibilidade.toMap());
    return disponibilidade;
  }

  @override
  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}