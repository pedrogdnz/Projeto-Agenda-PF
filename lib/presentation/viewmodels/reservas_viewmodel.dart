import 'package:flutter/material.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';
import 'package:agendapf/data/services/fake/fake_horario_service.dart';
import 'package:agendapf/data/services/fake/fake_reserva_service.dart';

/// Junta uma [Reserva] com o [Horario] correspondente para exibição na tela.
class ReservaComHorario {
  final Reserva reserva;
  final Horario? horario;

  const ReservaComHorario({required this.reserva, this.horario});
}

class ReservasViewModel extends ChangeNotifier {
  final ReservaService _reservaService;
  final HorarioService _horarioService;

  ReservasViewModel({
    ReservaService? reservaService,
    HorarioService? horarioService,
  }) : _reservaService = reservaService ?? FakeReservaService(),
       _horarioService = horarioService ?? FakeHorarioService();

  bool _carregando = true;
  List<ReservaComHorario> _reservas = [];

  bool get carregando => _carregando;
  List<ReservaComHorario> get reservas => _reservas;

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
