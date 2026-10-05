import 'package:agendapf/presentation/views/admin_reservas_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class AdminReservaEditarViewModel extends ChangeNotifier {
  final ReservaDoAluno item;
  final AgendaRepository _agendaRepository;

  final descricaoController = TextEditingController();

  AdminReservaEditarViewModel({
    required this.item,
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository,
       _data = item.reserva.dataReserva,
       _fundoSelecionado = item.reserva.corFundo,
       _horarioSelecionado = item.horario {
    descricaoController.text = item.reserva.descricao;
  }

  DateTime _data;
  CorFundoHorario _fundoSelecionado;
  Horario? _horarioSelecionado;

  Map<DateTime, MotivoBloqueio> _diasBloqueados = {};
  Set<DiaSemana>? _diasSemanaAtivos;
  List<HorarioDoDia> _horariosDoDia = [];

  bool _carregando = true;
  bool _carregandoHorarios = false;
  bool _salvando = false;
  String? _erro;

  DateTime get data => _data;
  CorFundoHorario get fundoSelecionado => _fundoSelecionado;
  Horario? get horarioSelecionado => _horarioSelecionado;
  List<HorarioDoDia> get horariosDoDia => _horariosDoDia;
  bool get carregando => _carregando;
  bool get carregandoHorarios => _carregandoHorarios;
  bool get salvando => _salvando;
  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    try {
      _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();
      _diasSemanaAtivos = await _agendaRepository.buscarDiasSemanaAtivos();
      _horariosDoDia = await _agendaRepository.buscarHorariosDoDia(
        _data,
        ignorarReservaId: item.reserva.id,
      );
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  bool diaSelecionavel(DateTime dia) {
    return _agendaRepository.diaSelecionavel(
      dia,
      _diasBloqueados,
      diasSemanaAtivos: _diasSemanaAtivos,
    );
  }

  /// Data inicial segura para o DatePicker (que exige initialDate válido).
  DateTime get dataInicialParaPicker {
    var candidato = DateTime(_data.year, _data.month, _data.day);
    for (var i = 0; i < 366; i++) {
      if (diaSelecionavel(candidato)) return candidato;
      candidato = candidato.add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  Future<void> selecionarData(DateTime nova) async {
    _data = DateTime(nova.year, nova.month, nova.day);
    _carregandoHorarios = true;
    notifyListeners();

    try {
      _horariosDoDia = await _agendaRepository.buscarHorariosDoDia(
        _data,
        ignorarReservaId: item.reserva.id,
      );
      _limparHorarioSeIndisponivel();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregandoHorarios = false;
      notifyListeners();
    }
  }

  void selecionarFundo(CorFundoHorario fundo) {
    if (_fundoSelecionado == fundo) return;
    _fundoSelecionado = fundo;
    _limparHorarioSeIndisponivel();
    notifyListeners();
  }

  void selecionarHorario(HorarioDoDia horarioDoDia) {
    if (!horarioDoDia.disponivelPara(_fundoSelecionado)) return;
    _horarioSelecionado = horarioDoDia.horario;
    notifyListeners();
  }

  void _limparHorarioSeIndisponivel() {
    final atual = _horarioSelecionado;
    if (atual == null) return;

    HorarioDoDia? encontrado;
    for (final h in _horariosDoDia) {
      if (h.horario.id == atual.id) encontrado = h;
    }
    if (encontrado == null || !encontrado.disponivelPara(_fundoSelecionado)) {
      _horarioSelecionado = null;
    }
  }

  Future<bool> salvar() async {
    if (_horarioSelecionado == null) {
      _erro = 'Selecione um horário disponível';
      notifyListeners();
      return false;
    }

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendaRepository.atualizarReserva(
        reservaId: item.reserva.id,
        horarioId: _horarioSelecionado!.id,
        data: _data,
        corFundo: _fundoSelecionado,
        descricao: descricaoController.text.trim(),
      );
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  void limparErro() => _erro = null;

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }
}
