import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
// TODO - O USUARIO PODE BOTAR QUANTOS CARACTERES ELE QUISER, AI QUEBRA 
class ReservaComHorario {
  final Reserva reserva;
  final Horario? horario;

  const ReservaComHorario({required this.reserva, this.horario});
}

enum TipoFiltroReserva { ativas, passadas }

class ReservasViewModel extends ChangeNotifier {
  final String alunoId;
  final AgendaRepository _agendaRepository;

  ReservasViewModel({
    required this.alunoId,
    required AgendaRepository agendaRepository,
  }) : _agendaRepository = agendaRepository;

  bool _carregando = true;
  List<ReservaComHorario> _reservas = [];
  TipoFiltroReserva _filtroAtual = TipoFiltroReserva.ativas;
  String? _erro;

  bool get carregando => _carregando;
  TipoFiltroReserva get filtroAtual => _filtroAtual;
  String? get erro => _erro;

  List<ReservaComHorario> get reservasFiltradas {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);

    final doAluno = _reservas.where((r) => r.reserva.alunoId == alunoId);

    if (_filtroAtual == TipoFiltroReserva.ativas) {
      return doAluno
          .where((r) => !r.reserva.dataReserva.isBefore(inicioHoje))
          .toList();
    } else {
      return doAluno
          .where((r) => r.reserva.dataReserva.isBefore(inicioHoje))
          .toList();
    }
  }

  void alterarFiltro(TipoFiltroReserva novoFiltro) {
    if (_filtroAtual != novoFiltro) {
      _filtroAtual = novoFiltro;
      notifyListeners();
    }
  }

  Future<void> carregarReservas() async {
    _carregando = true;
    notifyListeners();

    final reservas = await _agendaRepository.reservaService.buscarTodas();
    final horarios = await _agendaRepository.horarioService.buscarTodos();
    final horariosPorId = {for (final h in horarios) h.id: h};

    _reservas = reservas
        .map(
          (r) => ReservaComHorario(
            reserva: r,
            horario: horariosPorId[r.horarioId],
          ),
        )
        .toList();

    _carregando = false;
    notifyListeners();
  }

  Future<bool> cancelarReserva(String id) async {
    _erro = null;

    try {
      await _agendaRepository.cancelarReserva(
        reservaId: id,
        alunoIdSolicitante: alunoId,
      );
      await carregarReservas();
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }
}
