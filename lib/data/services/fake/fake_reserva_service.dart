import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';

class FakeReservaService implements ReservaService {
  final List<Reserva> _reservas = [
    Reserva(
      id: '1',
      alunoId: '1',
      horarioId: '1',
      dataReserva: DateTime(2026, 8, 25),
    ),
    Reserva(
      id: '2',
      alunoId: '2',
      horarioId: '2',
      dataReserva: DateTime(2026, 8, 26),
    ),
    Reserva(
      id: '3',
      alunoId: '3',
      horarioId: '3',
      dataReserva: DateTime(2026, 8, 27),
    ),
  ];

  @override
  Future<List<Reserva>> buscarTodas() async {
    return List.unmodifiable(_reservas);
  }
}
