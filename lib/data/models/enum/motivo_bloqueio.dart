enum MotivoBloqueio {
  ferias,
  feriados,
  outros;

  static MotivoBloqueio fromNome(String nome) {
    return MotivoBloqueio.values.firstWhere(
      (motivo) => motivo.name == nome,
      orElse: () => MotivoBloqueio.feriados,
    );
  }
}