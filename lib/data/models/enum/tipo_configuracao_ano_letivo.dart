enum TipoConfiguracaoAnoLetivo {
  ferias,
  feriados,
  horariosGerais;

  String get titulo {
    switch (this) {
      case TipoConfiguracaoAnoLetivo.ferias:
        return 'Configurando férias';
      case TipoConfiguracaoAnoLetivo.feriados:
        return 'Configurando feriados';
      case TipoConfiguracaoAnoLetivo.horariosGerais:
        return 'Configurando horários gerais';
    }
  }
}
