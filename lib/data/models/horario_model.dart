enum CorFundoHorario {
  preto,
  branco;

  static CorFundoHorario fromNome(String nome) {
    return CorFundoHorario.values.firstWhere(
      (cor) => cor.name == nome,
      orElse: () => CorFundoHorario.branco,
    );
  }
}

class Horario {
  final String id;
  final String horaInicial;
  final String horaFinal;
  final CorFundoHorario corFundo;
  final String descricao;

  const Horario({
    required this.id,
    required this.horaInicial,
    required this.horaFinal,
    required this.corFundo,
    this.descricao = '',
  });

  Horario copyWith({
    String? id,
    String? horaInicial,
    String? horaFinal,
    CorFundoHorario? corFundo,
    String? descricao,
  }) {
    return Horario(
      id: id ?? this.id,
      horaInicial: horaInicial ?? this.horaInicial,
      horaFinal: horaFinal ?? this.horaFinal,
      corFundo: corFundo ?? this.corFundo,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'horaInicial': horaInicial,
      'horaFinal': horaFinal,
      'corFundo': corFundo.name,
      'descricao': descricao,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as String,
      horaInicial: map['horaInicial'] as String,
      horaFinal: map['horaFinal'] as String,
      corFundo: CorFundoHorario.fromNome(
        map['corFundo'] as String? ?? 'branco',
      ),
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
        other.corFundo == corFundo &&
        other.descricao == descricao;
  }

  @override
  int get hashCode {
    return Object.hash(id, horaInicial, horaFinal, corFundo, descricao);
  }

  @override
  String toString() {
    return 'Horario(id: $id, horaInicial: $horaInicial, horaFinal: $horaFinal, '
        'corFundo: $corFundo, descricao: $descricao)';
  }
}
