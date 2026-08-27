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
