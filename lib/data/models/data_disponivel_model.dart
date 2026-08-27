class DataDisponivel {
  final String id;
  final DateTime data;

  const DataDisponivel({
    required this.id,
    required this.data,
  });

  /// Cria uma cópia desta DataDisponivel, substituindo apenas os campos informados.
  DataDisponivel copyWith({
    String? id,
    DateTime? data,
  }) {
    return DataDisponivel(
      id: id ?? this.id,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toIso8601String(),
    };
  }

  factory DataDisponivel.fromMap(Map<String, dynamic> map) {
    return DataDisponivel(
      id: map['id'] as String,
      data: DateTime.parse(map['data'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataDisponivel && other.id == id && other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, data);

  @override
  String toString() => 'DataDisponivel(id: $id, data: $data)';
}