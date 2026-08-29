import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/tipo_configuracao_ano_letivo.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class AnoLetivoViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository;

  AnoLetivoViewModel({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  DateTime _focusedDay = DateTime.now();
  TipoConfiguracaoAnoLetivo? _modoAtivo;
  final Set<DateTime> _datasSelecionadas = {};
  Set<DateTime> _diasBloqueados = {};

  bool _carregandoDiasBloqueados = true;
  bool _confirmando = false;
  String? _erro;
  String? _mensagemInfo;

  DateTime get focusedDay => _focusedDay;
  TipoConfiguracaoAnoLetivo? get modoAtivo => _modoAtivo;
  Set<DateTime> get datasSelecionadas => Set.unmodifiable(_datasSelecionadas);
  Set<DateTime> get diasBloqueados => Set.unmodifiable(_diasBloqueados);
  bool get carregandoDiasBloqueados => _carregandoDiasBloqueados;
  bool get confirmando => _confirmando;
  String? get erro => _erro;
  String? get mensagemInfo => _mensagemInfo;

  Future<void> carregarDiasBloqueados() async {
    _carregandoDiasBloqueados = true;
    notifyListeners();

    _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();

    _carregandoDiasBloqueados = false;
    notifyListeners();
  }

  void ativarModoFerias() {
    _modoAtivo = TipoConfiguracaoAnoLetivo.ferias;
    _datasSelecionadas.clear();
    notifyListeners();
  }

  void ativarModoFeriados() {
    _modoAtivo = TipoConfiguracaoAnoLetivo.feriados;
    _datasSelecionadas.clear();
    notifyListeners();
  }

  ///TODO - RF ainda não implementada — apenas sinaliza para a View exibir o aviso.
  void tentarAbrirHorariosGerais() {
    _mensagemInfo = 'Tela ainda não implementada';
    notifyListeners();
  }

  void limparMensagemInfo() {
    _mensagemInfo = null;
  }

  void cancelarModo() {
    _modoAtivo = null;
    _datasSelecionadas.clear();
    notifyListeners();
  }

  bool diaSelecionavel(DateTime dia) {
    final hoje = _normalizarData(DateTime.now());
    return !_normalizarData(dia).isBefore(hoje);
  }

  void adicionarDataArrastada(DateTime dia) {
    if (_modoAtivo != TipoConfiguracaoAnoLetivo.ferias) return;

    final diaNormalizado = _normalizarData(dia);
    if (!diaSelecionavel(diaNormalizado)) return;
    if (_diasBloqueados.contains(diaNormalizado)) return;
    if (_datasSelecionadas.contains(diaNormalizado)) return;

    _datasSelecionadas.add(diaNormalizado);
    notifyListeners();
  }

  void alternarDataTocada(DateTime dia) {
    if (_modoAtivo != TipoConfiguracaoAnoLetivo.feriados) return;

    final diaNormalizado = _normalizarData(dia);
    if (!diaSelecionavel(diaNormalizado)) return;
    if (_diasBloqueados.contains(diaNormalizado)) return;

    if (_datasSelecionadas.contains(diaNormalizado)) {
      _datasSelecionadas.remove(diaNormalizado);
    } else {
      _datasSelecionadas.add(diaNormalizado);
    }
    notifyListeners();
  }

  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  Future<bool> confirmar() async {
    if (_datasSelecionadas.isEmpty) {
      _erro = 'Selecione ao menos uma data antes de confirmar.';
      notifyListeners();
      return false;
    }

    _confirmando = true;
    _erro = null;
    notifyListeners();

    try {
      await _agendaRepository.bloquearDatas(_datasSelecionadas.toList());
      _datasSelecionadas.clear();
      _modoAtivo = null;
      await carregarDiasBloqueados();
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

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }
}
