class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final String senha;
  final DateTime criadoEm;

  const Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
    required this.senha,
    required this.criadoEm,
  });

  /// Cria uma cópia deste Aluno, substituindo apenas os campos informados.
  Aluno copyWith({
    String? id,
    String? nome,
    String? matricula,
    String? email,
    String? senha,
    DateTime? criadoEm,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
      senha: senha ?? this.senha,
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
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  factory Aluno.fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as String,
      nome: map['nome'] as String,
      matricula: map['matricula'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
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
        other.criadoEm == criadoEm;
  }

  @override
  int get hashCode {
    return Object.hash(id, nome, matricula, email, senha, criadoEm);
  }

  @override
  String toString() {
    return 'Aluno(id: $id, nome: $nome, matricula: $matricula, email: $email, criadoEm: $criadoEm)';
  }
}
