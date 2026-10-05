import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';

class FirebaseReservaService implements ReservaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('reservas');

  @override
  Future<List<Reserva>> buscarTodas() async {
    final snapshot = await _colecao.get();
    return snapshot.docs.map((doc) => Reserva.fromMap(doc.data())).toList();
  }

  @override
  Future<Reserva?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return Reserva.fromMap(doc.data()!);
  }

  @override
  Future<Reserva> criar(Reserva reserva) async {
    final docRef = _colecao.doc(); // sempre gerado pelo Firestore
    final reservaComId = reserva.copyWith(id: docRef.id);
    await docRef.set(reservaComId.toMap());
    return reservaComId;
  }

  @override
  Future<Reserva> atualizar(Reserva reserva) async {
    await _colecao.doc(reserva.id).update(reserva.toMap());
    return reserva;
  }

  @override
  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}