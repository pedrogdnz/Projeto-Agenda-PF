import 'dart:convert';

/// Representa o vínculo entre um Aluno e um Horario reservado (RF05).

class Reserva {
  final String id;
  final String alunoId;
  final String horarioId;
  final DateTime dataReserva;

  const Reserva({
    required this.id,
    required this.alunoId,
    required this.horarioId,
    required this.dataReserva,
  });

    Reserva copyWith({
    String? id,
    String? alunoId,
    String? horarioId,
    DateTime? dataReserva,
  }) {
    return Reserva(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      horarioId: horarioId ?? this.horarioId,
      dataReserva: dataReserva ?? this.dataReserva,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alunoId': alunoId,
      'horarioId': horarioId,
      'dataReserva': dataReserva.toIso8601String(),
    };
  }

  factory Reserva.fromMap(Map<String, dynamic> map) {
    return Reserva(
      id: map['id'] as String,
      alunoId: map['alunoId'] as String,
      horarioId: map['horarioId'] as String,
      dataReserva: DateTime.parse(map['dataReserva'] as String),
    );
  }

  /// Serializa a reserva para uma string JSON.
  String toJson() => jsonEncode(toMap());

  /// Cria uma Reserva a partir de uma string JSON.
  factory Reserva.fromJson(String source) =>
      Reserva.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva &&
        other.id == id &&
        other.alunoId == alunoId &&
        other.horarioId == horarioId &&
        other.dataReserva == dataReserva;
  }

  @override
  int get hashCode {
    return Object.hash(id, alunoId, horarioId, dataReserva);
  }

  @override
  String toString() {
    return 'Reserva(id: $id, alunoId: $alunoId, horarioId: $horarioId, '
        'dataReserva: $dataReserva)';
  }
}