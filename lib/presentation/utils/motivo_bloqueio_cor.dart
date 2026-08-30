import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';

/// Mapeamento único de cor por motivo, usado tanto no calendário do
/// aluno quanto no do administrador — evita duas fontes de verdade
Color corParaMotivoBloqueio(MotivoBloqueio motivo) {
  return motivo == MotivoBloqueio.ferias ? Colors.red : Colors.blue;
}