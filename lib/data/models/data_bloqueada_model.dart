class DataBloqueada {
  final String id;
  final DateTime data;

  const DataBloqueada({
    required this.id,
    required this.data,
  });

  DataBloqueada copyWith({
    String? id,
    DateTime? data,
  }) {
    return DataBloqueada(
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

  factory DataBloqueada.fromMap(Map<String, dynamic> map) {
    return DataBloqueada(
      id: map['id'] as String,
      data: DateTime.parse(map['data'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataBloqueada && other.id == id && other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, data);

  @override
  String toString() => 'DataBloqueada(id: $id, data: $data)';
}