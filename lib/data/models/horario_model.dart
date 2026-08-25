// lib/data/models/horario.dart

/// Representa um horário do catálogo fixo/recorrente oferecido pela
/// instituição (ex: "08:00 às 09:00"). É o MESMO conjunto de horários que
/// se repete em todo dia aberto — não pertence a uma data específica.
///
/// A disponibilidade de um Horario em um dia específico (se já foi
/// reservado, se já passou, etc.) é calculada dinamicamente pelo
/// AgendaRepository, cruzando este catálogo com [Reserva] e com o dia
/// bloqueado ou não — por isso este model não guarda `disponivel` nem
/// `dataId`.
class Horario {
  final String id;
  final String horaInicial;
  final String horaFinal;
  final String descricao;

  const Horario({
    required this.id,
    required this.horaInicial,
    required this.horaFinal,
    this.descricao = '',
  });

  Horario copyWith({
    String? id,
    String? horaInicial,
    String? horaFinal,
    String? descricao,
  }) {
    return Horario(
      id: id ?? this.id,
      horaInicial: horaInicial ?? this.horaInicial,
      horaFinal: horaFinal ?? this.horaFinal,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'horaInicial': horaInicial,
      'horaFinal': horaFinal,
      'descricao': descricao,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as String,
      horaInicial: map['horaInicial'] as String,
      horaFinal: map['horaFinal'] as String,
      descricao: map['descricao'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Horario &&
        other.id == id &&
        other.horaInicial == horaInicial &&
        other.horaFinal == horaFinal &&
        other.descricao == descricao;
  }

  @override
  int get hashCode => Object.hash(id, horaInicial, horaFinal, descricao);

  @override
  String toString() {
    return 'Horario(id: $id, horaInicial: $horaInicial, horaFinal: $horaFinal, '
        'descricao: $descricao)';
  }
}