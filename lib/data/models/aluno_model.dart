class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final String? senha;
  final String? fotoBase64;
  final DateTime criadoEm;

  const Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
    this.senha,
    required this.criadoEm, this.fotoBase64,
  });

  /// Cria uma cópia deste Aluno, substituindo apenas os campos informados.
  Aluno copyWith({
    String? id,
    String? nome,
    String? matricula,
    String? email,
    String? senha,
    String? fotoBase64,
    bool removerFoto = false,
    DateTime? criadoEm,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      fotoBase64: removerFoto
      ? null
        : (fotoBase64 ?? this.fotoBase64),
    criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'email': email,
      'senha': senha,
      'fotoBase64': fotoBase64,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Aluno.fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as String,
      nome: map['nome'] as String,
      matricula: map['matricula'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String?,
      fotoBase64: map['fotoBase64'] as String?, // NOVO
      criadoEm: DateTime.parse(map['criadoEm'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Aluno &&
        other.id == id &&
        other.nome == nome &&
        other.matricula == matricula &&
        other.email == email &&
        other.senha == senha &&
        other.fotoBase64 == fotoBase64 &&
        other.criadoEm == criadoEm;
  }

  @override
  int get hashCode {
    return Object.hash(id, nome, matricula, email, senha, fotoBase64, criadoEm);
  }

  @override
  String toString() {
    return 'Aluno(id: $id, nome: $nome, matricula: $matricula, email: $email, criadoEm: $criadoEm)';
  }
}
