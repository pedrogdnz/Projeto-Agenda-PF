class Horario {
  final String id;
  final String horaInicial;
  final String horaFinal;

  const Horario({
    required this.id,
    required this.horaInicial,
    required this.horaFinal,
  });

  Horario copyWith({String? id, String? horaInicial, String? horaFinal}) {
    return Horario(
      id: id ?? this.id,
      horaInicial: horaInicial ?? this.horaInicial,
      horaFinal: horaFinal ?? this.horaFinal,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'horaInicial': horaInicial, 'horaFinal': horaFinal};
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as String,
      horaInicial: map['horaInicial'] as String,
      horaFinal: map['horaFinal'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Horario &&
        other.id == id &&
        other.horaInicial == horaInicial &&
        other.horaFinal == horaFinal;
  }

  @override
  int get hashCode => Object.hash(id, horaInicial, horaFinal);

  @override
  String toString() =>
      'Horario(id: $id, horaInicial: $horaInicial, horaFinal: $horaFinal)';
}
