enum Turma {
  pf1,
  pf2,
  pf3,
  pav1,
  pav2,
  pav3;

  /// Texto exibido na tela: "PF1", "PAV2"...
  String get titulo => name.toUpperCase();

  /// Devolve null quando o valor não existe (alunos antigos, sem o campo).
  static Turma? fromNome(String? nome) {
    if (nome == null) return null;
    for (final turma in Turma.values) {
      if (turma.name == nome) return turma;
    }
    return null;
  }
}