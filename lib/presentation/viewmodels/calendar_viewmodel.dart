import 'package:flutter/material.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository;

  CalendarViewModel({required AgendaRepository agendaRepository})
    : _agendaRepository = agendaRepository;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _dayToOpen;

  /// Mensagem de erro exibida quando o aluno toca em um dia indisponível
  /// (fora do período, bloqueado ou já no passado). É um valor "de disparo
  /// único": a View deve chamar [limparErroSelecao] logo após exibi-la.
  String? _erroSelecao;

  Set<DateTime> _diasBloqueados = {};
  bool _carregandoDiasBloqueados = true;

  List<HorarioDoDia> _horariosDoDiaSelecionado = [];
  bool _carregandoHorarios = false;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get dayToOpen => _dayToOpen;
  String? get erroSelecao => _erroSelecao;

  bool get carregandoDiasBloqueados => _carregandoDiasBloqueados;

  List<HorarioDoDia> get horariosDoDiaSelecionado => _horariosDoDiaSelecionado;

  bool get carregandoHorarios => _carregandoHorarios;

  Future<void> carregarDiasBloqueados() async {
    _carregandoDiasBloqueados = true;
    notifyListeners();

    _diasBloqueados = await _agendaRepository.buscarDiasBloqueados();

    _carregandoDiasBloqueados = false;
    notifyListeners();
  }

  bool diaSelecionavel(DateTime dia) {
    return _agendaRepository.diaSelecionavel(dia, _diasBloqueados);
  }

  /// Um único toque em um dia disponível já seleciona a data e sinaliza
  /// para a View abrir a tela de Detalhes. Um toque em um dia indisponível
  /// não navega — apenas expõe uma mensagem de erro via [erroSelecao].
  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (!diaSelecionavel(selectedDay)) {
      _erroSelecao = 'Esta data não está disponível para reserva.';
      notifyListeners();
      return;
    }

    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _dayToOpen = selectedDay;

    notifyListeners();

    carregarHorariosDoDia(selectedDay);
  }

  Future<void> carregarHorariosDoDia(DateTime dia) async {
    _carregandoHorarios = true;
    notifyListeners();

    _horariosDoDiaSelecionado = await _agendaRepository.buscarHorariosDoDia(
      dia,
    );

    _carregandoHorarios = false;
    notifyListeners();
  }

  void clearDayToOpen() {
    _dayToOpen = null;
  }

  void limparErroSelecao() {
    _erroSelecao = null;
  }

  void changePage(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }
}
