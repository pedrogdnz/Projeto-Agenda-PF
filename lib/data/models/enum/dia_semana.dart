/// Dias da semana na mesma ordem de [DateTime.weekday] (segunda = 1 ... domingo = 7).
enum DiaSemana {
  segunda,
  terca,
  quarta,
  quinta,
  sexta,
  sabado,
  domingo;

  /// Valor equivalente a [DateTime.weekday] (1 a 7).
  int get weekday => index + 1;

  String get titulo {
    switch (this) {
      case DiaSemana.segunda:
        return 'Segunda-feira';
      case DiaSemana.terca:
        return 'Terça-feira';
      case DiaSemana.quarta:
        return 'Quarta-feira';
      case DiaSemana.quinta:
        return 'Quinta-feira';
      case DiaSemana.sexta:
        return 'Sexta-feira';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }

  static DiaSemana fromWeekday(int weekday) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError.value(weekday, 'weekday', 'Deve estar entre 1 e 7.');
    }
    return DiaSemana.values[weekday - 1];
  }

  static DiaSemana fromData(DateTime data) => fromWeekday(data.weekday);

  static DiaSemana fromNome(String nome) {
    return DiaSemana.values.firstWhere(
      (dia) => dia.name == nome,
      orElse: () => DiaSemana.segunda,
    );
  }
}