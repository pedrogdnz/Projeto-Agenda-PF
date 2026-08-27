import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';
import 'package:agendapf/data/services/fake/fake_horario_service.dart';
import 'package:agendapf/data/services/fake/fake_reserva_service.dart';

class ReservaComHorario {
  final Reserva reserva;
  final Horario? horario;

  const ReservaComHorario({required this.reserva, this.horario});
}

enum TipoFiltroReserva { ativas, passadas }

class ReservasViewModel extends ChangeNotifier {
  final String alunoId;

  final ReservaService _reservaService;
  final HorarioService _horarioService;

  ReservasViewModel({
    required this.alunoId,
    ReservaService? reservaService,
    HorarioService? horarioService,
  }) : _reservaService = reservaService ?? FakeReservaService(),
       _horarioService = horarioService ?? FakeHorarioService();

  bool _carregando = true;
  List<ReservaComHorario> _reservas = [];
  TipoFiltroReserva _filtroAtual = TipoFiltroReserva.ativas;

  bool get carregando => _carregando;
  TipoFiltroReserva get filtroAtual => _filtroAtual;

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

    final reservas = await _reservaService.buscarTodas();
    final horarios = await _horarioService.buscarTodos();
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

  Future<void> cancelarReserva(String id) async {
    await _reservaService.excluir(id);
    await carregarReservas();
  }
}
