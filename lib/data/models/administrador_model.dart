class Administrador {
  final String id;
  final String nome;
  final String email;
  final String senha;

  const Administrador({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  Administrador copyWith({
    String? id,
    String? nome,
    String? email,
    String? senha,
  }) {
    return Administrador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  factory Administrador.fromMap(Map<String, dynamic> map) {
    return Administrador(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Administrador &&
        other.id == id &&
        other.nome == nome &&
        other.email == email &&
        other.senha == senha;
  }

  @override
  int get hashCode {
    return Object.hash(id, nome, email, senha);
  }

  @override
  String toString() {
    return 'Administrador(id: $id, nome: $nome, email: $email)';
  }
}