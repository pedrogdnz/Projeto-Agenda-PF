// lib/presentation/viewmodels/

import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';

class DetalhesViewModel extends ChangeNotifier {
  final DateTime data;

  final descricaoController = TextEditingController();

  DetalhesViewModel({required this.data});

  TimeOfDay? _horaInicialSelecionada;
  TimeOfDay? _horaFinalSelecionada;
  CorFundoHorario _corFundoSelecionada = CorFundoHorario.preto;

  TimeOfDay? get horaInicialSelecionada => _horaInicialSelecionada;
  TimeOfDay? get horaFinalSelecionada => _horaFinalSelecionada;
  CorFundoHorario get corFundoSelecionada => _corFundoSelecionada;

  void selecionarHoraInicial(TimeOfDay horario) {
    _horaInicialSelecionada = horario;

    // Se a hora final já escolhida deixou de ser válida em relação à nova
    // hora inicial (antes ou igual a ela), limpa para forçar nova escolha.
    if (_horaFinalSelecionada != null &&
        !_horaEhDepois(_horaFinalSelecionada!, horario)) {
      _horaFinalSelecionada = null;
    }

    notifyListeners();
  }

  void selecionarHoraFinal(TimeOfDay horario) {
    _horaFinalSelecionada = horario;
    notifyListeners();
  }

  void selecionarCorFundo(CorFundoHorario cor) {
    _corFundoSelecionada = cor;
    notifyListeners();
  }

  /// Retorna true se [horario] for estritamente posterior a [referencia].
  bool _horaEhDepois(TimeOfDay horario, TimeOfDay referencia) {
    final minutosHorario = horario.hour * 60 + horario.minute;
    final minutosReferencia = referencia.hour * 60 + referencia.minute;
    return minutosHorario > minutosReferencia;
  }

  /// Valida a seleção de horário inicial/final (RN04).
  String? validarSelecao() {
    if (_horaInicialSelecionada == null) {
      return 'Selecione o horário inicial';
    }

    if (_horaFinalSelecionada == null) {
      return 'Selecione o horário final';
    }

    if (!_horaEhDepois(_horaFinalSelecionada!, _horaInicialSelecionada!)) {
      return 'O horário final deve ser depois do horário inicial';
    }

    return null;
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }
}
