import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';

class DetalhesViewModel extends ChangeNotifier {
  final DateTime data;

  final descricaoController = TextEditingController();

  DetalhesViewModel({required this.data});

  TimeOfDay? _horarioSelecionado;
  CorFundoHorario _corFundoSelecionada = CorFundoHorario.preto;

  TimeOfDay? get horarioSelecionado => _horarioSelecionado;
  CorFundoHorario get corFundoSelecionada => _corFundoSelecionada;

  void selecionarHorario(TimeOfDay horario) {
    _horarioSelecionado = horario;
    notifyListeners();
  }

  void selecionarCorFundo(CorFundoHorario cor) {
    _corFundoSelecionada = cor;
    notifyListeners();
  }

  /// Retorna uma mensagem de erro se a seleção estiver incompleta,
  /// ou `null` se estiver tudo certo para confirmar a reserva.
  String? validarSelecao() {
    if (_horarioSelecionado == null) {
      return 'Selecione um horário';
    }
    return null;
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }
}
