import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class DetalhesViewModel extends ChangeNotifier {
  final DateTime data;
  final String alunoId;
  final AgendaRepository _agendaRepository;

  final descricaoController = TextEditingController();

  DetalhesViewModel({
    required this.data,
    required this.alunoId,
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository;

  bool _carregandoHorarios = true;
  List<HorarioDoDia> _horariosDoDia = [];
  Horario? _horarioSelecionado;
  CorFundoHorario _fundoSelecionado = CorFundoHorario.branco;

  bool _confirmando = false;
  String? _erro;
  bool _reservaConfirmada = false;

  bool get carregandoHorarios => _carregandoHorarios;
  List<HorarioDoDia> get horariosDoDia => _horariosDoDia;
  Horario? get horarioSelecionado => _horarioSelecionado;
  CorFundoHorario get fundoSelecionado => _fundoSelecionado;
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
    if (!horarioDoDia.disponivelPara(_fundoSelecionado)) return;

    _horarioSelecionado = horarioDoDia.horario;
    notifyListeners();
  }

  /// Troca o fundo escolhido. Se o horário já selecionado não estiver mais
  /// disponível para o novo fundo, a seleção é limpa (evita confirmar uma
  /// combinação horário+fundo que já está ocupada).
  void selecionarFundo(CorFundoHorario fundo) {
    if (_fundoSelecionado == fundo) return;
    _fundoSelecionado = fundo;

    final horarioAtual = _horarioSelecionado;
    if (horarioAtual != null) {
      final item = _horariosDoDia
          .where((h) => h.horario.id == horarioAtual.id)
          .cast<HorarioDoDia?>()
          .firstWhere((h) => true, orElse: () => null);

      if (item == null || !item.disponivelPara(fundo)) {
        _horarioSelecionado = null;
      }
    }

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
        corFundo: _fundoSelecionado,
        descricao: descricaoController.text.trim(),
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
