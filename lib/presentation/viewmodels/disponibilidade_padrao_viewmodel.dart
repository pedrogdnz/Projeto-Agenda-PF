// lib/presentation/viewmodels/disponibilidade_padrao_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/disponibilidade_padrao_repository.dart';

class DisponibilidadePadraoViewModel extends ChangeNotifier {
  final DisponibilidadePadraoRepository _repository;

  DisponibilidadePadraoViewModel({
    required DisponibilidadePadraoRepository repository,
  }) : _repository = repository;

  bool _carregando = true;
  List<Horario> _horarios = [];

  final Map<DiaSemana, Set<String>> _selecao = {};
  final Map<DiaSemana, Set<String>> _salvo = {};

  DiaSemana? _salvandoDia;
  String? _erro;
  String? _mensagemInfo;

  bool get carregando => _carregando;
  List<Horario> get horarios => List.unmodifiable(_horarios);
  DiaSemana? get salvandoDia => _salvandoDia;
  String? get erro => _erro;
  String? get mensagemInfo => _mensagemInfo;

  Set<String> selecionados(DiaSemana dia) =>
      Set.unmodifiable(_selecao[dia] ?? const <String>{});

  bool estaSelecionado(DiaSemana dia, String horarioId) =>
      _selecao[dia]?.contains(horarioId) ?? false;

  bool temAlteracoes(DiaSemana dia) {
    final atual = _selecao[dia] ?? const <String>{};
    final original = _salvo[dia] ?? const <String>{};
    return atual.length != original.length || !atual.containsAll(original);
  }

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    try {
      _horarios = await _repository.buscarHorarios();
      final semana = await _repository.buscarSemana();

      _selecao.clear();
      _salvo.clear();
      for (final item in semana) {
        _selecao[item.diaSemana] = Set.of(item.horarioIds);
        _salvo[item.diaSemana] = Set.of(item.horarioIds);
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void alternarHorario(DiaSemana dia, String horarioId) {
    final selecao = _selecao.putIfAbsent(dia, () => <String>{});
    if (!selecao.remove(horarioId)) selecao.add(horarioId);
    notifyListeners();
  }

  void selecionarTodos(DiaSemana dia) {
    _selecao[dia] = {for (final h in _horarios) h.id};
    notifyListeners();
  }

  void limparDia(DiaSemana dia) {
    _selecao[dia] = <String>{};
    notifyListeners();
  }

  void descartarAlteracoes(DiaSemana dia) {
    _selecao[dia] = Set.of(_salvo[dia] ?? const <String>{});
    notifyListeners();
  }

  Future<bool> salvarDia(DiaSemana dia) async {
    _salvandoDia = dia;
    _erro = null;
    notifyListeners();

    try {
      final salvo = await _repository.atualizarHorarios(
        diaSemana: dia,
        horarioIds: (_selecao[dia] ?? const <String>{}).toList(),
      );
      _selecao[dia] = Set.of(salvo.horarioIds);
      _salvo[dia] = Set.of(salvo.horarioIds);
      _mensagemInfo = '${dia.titulo}: horários padrão salvos.';
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _salvandoDia = null;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
  }

  void limparMensagemInfo() {
    _mensagemInfo = null;
  }
}
