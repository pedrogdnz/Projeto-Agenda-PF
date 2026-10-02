import 'package:agendapf/data/models/enum/dia_semana.dart';

/// Regra Geral: para cada dia da semana, quais [Horario]s (por id) estão
/// liberados por padrão. Lista vazia = o laboratório não atende nesse dia.
class DisponibilidadePadrao {
  final String id;
  final DiaSemana diaSemana;
  final List<String> horarioIds;

  const DisponibilidadePadrao({
    required this.id,
    required this.diaSemana,
    this.horarioIds = const [],
  });

  DisponibilidadePadrao copyWith({
    String? id,
    DiaSemana? diaSemana,
    List<String>? horarioIds,
  }) {
    return DisponibilidadePadrao(
      id: id ?? this.id,
      diaSemana: diaSemana ?? this.diaSemana,
      horarioIds: horarioIds ?? this.horarioIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'diaSemana': diaSemana.name, 'horarioIds': horarioIds};
  }

  factory DisponibilidadePadrao.fromMap(Map<String, dynamic> map) {
    return DisponibilidadePadrao(
      id: map['id'] as String,
      diaSemana: DiaSemana.fromNome(map['diaSemana'] as String),
      horarioIds: List<String>.from(map['horarioIds'] as List? ?? const []),
    );
  }

  bool _mesmosHorarios(List<String> outros) {
    if (horarioIds.length != outros.length) return false;
    for (var i = 0; i < horarioIds.length; i++) {
      if (horarioIds[i] != outros[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DisponibilidadePadrao &&
        other.id == id &&
        other.diaSemana == diaSemana &&
        _mesmosHorarios(other.horarioIds);
  }

  @override
  int get hashCode => Object.hash(id, diaSemana, Object.hashAll(horarioIds));

  @override
  String toString() =>
      'DisponibilidadePadrao(id: $id, diaSemana: $diaSemana, horarioIds: $horarioIds)';
}
