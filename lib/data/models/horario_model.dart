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
  final String dataId;
  final String horaInicial;
  final String horaFinal;
  final bool disponivel;
  final CorFundoHorario corFundo;
  final String descricao;

  const Horario({
    required this.id,
    required this.dataId,
    required this.horaInicial,
    required this.horaFinal,
    required this.disponivel,
    this.corFundo = CorFundoHorario.branco,
    this.descricao = '',
  });

  /// Cria uma cópia deste Horario, substituindo apenas os campos informados.
  Horario copyWith({
    String? id,
    String? dataId,
    String? horaInicial,
    String? horaFinal,
    bool? disponivel,
    CorFundoHorario? corFundo,
    String? descricao,
  }) {
    return Horario(
      id: id ?? this.id,
      dataId: dataId ?? this.dataId,
      horaInicial: horaInicial ?? this.horaInicial,
      horaFinal: horaFinal ?? this.horaFinal,
      disponivel: disponivel ?? this.disponivel,
      corFundo: corFundo ?? this.corFundo,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataId': dataId,
      'horaInicial': horaInicial,
      'horaFinal': horaFinal,
      'disponivel': disponivel,
      'corFundo': corFundo.name,
      'descricao': descricao,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as String,
      dataId: map['dataId'] as String,
      horaInicial: map['horaInicial'] as String,
      horaFinal: map['horaFinal'] as String,
      disponivel: map['disponivel'] as bool,
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
        other.dataId == dataId &&
        other.horaInicial == horaInicial &&
        other.horaFinal == horaFinal &&
        other.disponivel == disponivel &&
        other.corFundo == corFundo &&
        other.descricao == descricao;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      dataId,
      horaInicial,
      horaFinal,
      disponivel,
      corFundo,
      descricao,
    );
  }

  @override
  String toString() {
    return 'Horario(id: $id, dataId: $dataId, horaInicial: $horaInicial, '
        'horaFinal: $horaFinal, disponivel: $disponivel, corFundo: $corFundo, '
        'descricao: $descricao)';
  }
}
