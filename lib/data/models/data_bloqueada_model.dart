import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';

class DataBloqueada {
  final String id;
  final DateTime data;
  final MotivoBloqueio motivo;

  const DataBloqueada({
    required this.id,
    required this.data,
    required this.motivo,
  });

  DataBloqueada copyWith({String? id, DateTime? data, MotivoBloqueio? motivo}) {
    return DataBloqueada(
      id: id ?? this.id,
      data: data ?? this.data,
      motivo: motivo ?? this.motivo,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'data': data.toIso8601String(), 'motivo': motivo.name};
  }

  factory DataBloqueada.fromMap(Map<String, dynamic> map) {
    return DataBloqueada(
      id: map['id'] as String,
      data: DateTime.parse(map['data'] as String),
      motivo: MotivoBloqueio.fromNome(map['motivo'] as String? ?? 'feriados'),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataBloqueada &&
        other.id == id &&
        other.data == data &&
        other.motivo == motivo;
  }

  @override
  int get hashCode => Object.hash(id, data, motivo);

  @override
  String toString() => 'DataBloqueada(id: $id, data: $data, motivo: $motivo)';
}
