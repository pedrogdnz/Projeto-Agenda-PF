import 'dart:convert';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';

/// `corFundo` e `descricao` pertencem à reserva, não ao horário.
class Reserva {
  final String id;
  final String alunoId;
  final String horarioId;
  final DateTime dataReserva;
  final CorFundoHorario corFundo;
  final String descricao;

  const Reserva({
    required this.id,
    required this.alunoId,
    required this.horarioId,
    required this.dataReserva,
    required this.corFundo,
    this.descricao = '',
  });

  Reserva copyWith({
    String? id,
    String? alunoId,
    String? horarioId,
    DateTime? dataReserva,
    CorFundoHorario? corFundo,
    String? descricao,
  }) {
    return Reserva(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      horarioId: horarioId ?? this.horarioId,
      dataReserva: dataReserva ?? this.dataReserva,
      corFundo: corFundo ?? this.corFundo,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alunoId': alunoId,
      'horarioId': horarioId,
      'dataReserva': dataReserva.toIso8601String(),
      'corFundo': corFundo.name,
      'descricao': descricao,
    };
  }

  factory Reserva.fromMap(Map<String, dynamic> map) {
    return Reserva(
      id: map['id'] as String,
      alunoId: map['alunoId'] as String,
      horarioId: map['horarioId'] as String,
      dataReserva: DateTime.parse(map['dataReserva'] as String),
      corFundo: CorFundoHorario.fromNome(
        map['corFundo'] as String? ?? 'branco',
      ),
      descricao: map['descricao'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Reserva.fromJson(String source) =>
      Reserva.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva &&
        other.id == id &&
        other.alunoId == alunoId &&
        other.horarioId == horarioId &&
        other.dataReserva == dataReserva &&
        other.corFundo == corFundo &&
        other.descricao == descricao;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      alunoId,
      horarioId,
      dataReserva,
      corFundo,
      descricao,
    );
  }

  @override
  String toString() {
    return 'Reserva(id: $id, alunoId: $alunoId, horarioId: $horarioId, '
        'dataReserva: $dataReserva, corFundo: $corFundo, descricao: $descricao)';
  }
}
