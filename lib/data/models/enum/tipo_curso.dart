enum TipoCurso {
  integrado,
  subsequente;

  String get titulo {
    switch (this) {
      case TipoCurso.integrado:
        return 'Integrado';
      case TipoCurso.subsequente:
        return 'Subsequente';
    }
  }

  /// Devolve null quando o valor não existe (alunos antigos, sem o campo).
  static TipoCurso? fromNome(String? nome) {
    if (nome == null) return null;
    for (final tipo in TipoCurso.values) {
      if (tipo.name == nome) return tipo;
    }
    return null;
  }
}