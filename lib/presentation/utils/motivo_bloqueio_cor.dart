import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';

Color corParaMotivoBloqueio(MotivoBloqueio motivo) {
  switch (motivo) {
    case MotivoBloqueio.ferias:
      return Colors.red;
    case MotivoBloqueio.feriados:
      return Colors.blue;
    case MotivoBloqueio.outros:
      return Colors.green;
  }
}

String descricaoMotivoBloqueio(MotivoBloqueio motivo) {
  switch (motivo) {
    case MotivoBloqueio.ferias:
      return 'Férias';
    case MotivoBloqueio.feriados:
      return 'Feriados';
    case MotivoBloqueio.outros:
      return 'Bloqueado pelo administrador';
  }
}
