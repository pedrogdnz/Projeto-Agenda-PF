import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class DetalhesViewModel extends ChangeNotifier {
  final DateTime data;
  final String alunoId;
  final AgendaRepository _agendaRepository;

  //TODO - TA FALTANDO BOTAR O CAMPO DE DESCRIÇÃO NO MODEL

  final descricaoController = TextEditingController();

  DetalhesViewModel({
    required this.data,
    required this.alunoId,
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository;

  bool _carregandoHorarios = true;
  List<HorarioDoDia> _horariosDoDia = [];
  Horario? _horarioSelecionado;

  bool _confirmando = false;
  String? _erro;
  bool _reservaConfirmada = false;

  bool get carregandoHorarios => _carregandoHorarios;
  List<HorarioDoDia> get horariosDoDia => _horariosDoDia;
  Horario? get horarioSelecionado => _horarioSelecionado;
  bool get confirmando => _confirmando;
  String? get erro => _erro;
  bool get reservaConfirmada => _reservaConfirmada;

  Future<void> carregarHorarios() async {
    _carregandoHorarios = true;
    notifyListeners();

    _horariosDoDia = await _agendaRepository.buscarHorariosDoDia(data);

    _carregandoHorarios = false;
    notifyListeners();
  }

  void selecionarHorario(HorarioDoDia horarioDoDia) {
    if (!horarioDoDia.disponivel) return;

    _horarioSelecionado = horarioDoDia.horario;
    notifyListeners();
  }

  String? validarSelecao() {
    if (_horarioSelecionado == null) {
      return 'Selecione um horário disponível';
    }
    return null;
  }

  Future<bool> confirmarReserva() async {
    final erroValidacao = validarSelecao();
    if (erroValidacao != null) {
      _erro = erroValidacao;
      notifyListeners();
      return false;
    }

    _confirmando = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendaRepository.criarReserva(
        alunoId: alunoId,
        horarioId: _horarioSelecionado!.id,
        data: data,
      );
      _reservaConfirmada = true;
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _confirmando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }
}
