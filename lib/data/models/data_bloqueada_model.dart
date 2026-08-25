class DataBloqueada {
  final DateTime data;
  final bool bloqueado;

  const DataBloqueada({required this.data, this.bloqueado = true});

  DataBloqueada copyWith({DateTime? data, bool? bloqueado}) {
    return DataBloqueada(
      data: data ?? this.data,
      bloqueado: bloqueado ?? this.bloqueado,
    );
  }

  Map<String, dynamic> toMap() {
    return {'data': data.toIso8601String(), 'bloqueado': bloqueado};
  }

  factory DataBloqueada.fromMap(Map<String, dynamic> map) {
    return DataBloqueada(
      data: DateTime.parse(map['data'] as String),
      bloqueado: map['bloqueado'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataBloqueada &&
        other.data == data &&
        other.bloqueado == bloqueado;
  }

  @override
  int get hashCode => Object.hash(data, bloqueado);

  @override
  String toString() => 'DataBloqueada(data: $data, bloqueado: $bloqueado)';
}
