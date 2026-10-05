import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';

class FirebaseHorarioService implements HorarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _db.collection('horarios');

  @override
  Future<List<Horario>> buscarTodos() async {
    final snapshot = await _colecao.get();
    final lista = snapshot.docs.map((doc) => Horario.fromMap(doc.data())).toList();
    lista.sort((a, b) => a.horaInicial.compareTo(b.horaInicial));
    return lista;
  }

  @override
  Future<Horario?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (!doc.exists) return null;
    return Horario.fromMap(doc.data()!);
  }

  @override
  Future<Horario> criar(Horario horario) async {
    // Se vier sem id (criação nova), deixa o Firestore gerar um.
    final docRef = horario.id.isEmpty ? _colecao.doc() : _colecao.doc(horario.id);
    final horarioComId = horario.id.isEmpty ? horario.copyWith(id: docRef.id) : horario;
    await docRef.set(horarioComId.toMap());
    return horarioComId;
  }

  @override
  Future<Horario> atualizar(Horario horario) async {
    await _colecao.doc(horario.id).update(horario.toMap());
    return horario;
  }

  @override
  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}