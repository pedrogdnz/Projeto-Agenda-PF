import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';

class FakeReservaService implements ReservaService {
  final List<Reserva> _reservas = [
    Reserva(
      id: '1',
      alunoId: '1',
      horarioId: '1',
      dataReserva: DateTime(2026, 8, 25),
      corFundo: CorFundoHorario.branco,
      
    ),
    Reserva(
      id: '2',
      alunoId: '2',
      horarioId: '2',
      dataReserva: DateTime(2026, 8, 26),
      corFundo: CorFundoHorario.branco,
    ),
    Reserva(
      id: '3',
      alunoId: '3',
      horarioId: '3',
      dataReserva: DateTime(2026, 8, 27),
      corFundo: CorFundoHorario.branco,
    ),
  ];

  @override
  Future<List<Reserva>> buscarTodas() async {
    return List.unmodifiable(_reservas);
  }

  @override
  Future<Reserva?> buscarPorId(String id) async {
    for (final reserva in _reservas) {
      if (reserva.id == id) return reserva;
    }
    return null;
  }

  @override
  Future<Reserva> criar(Reserva reserva) async {
    final novaReserva = reserva.copyWith(id: _gerarProximoId());
    _reservas.add(novaReserva);
    return novaReserva;
  }

  @override
  Future<Reserva> atualizar(Reserva reserva) async {
    final index = _reservas.indexWhere((r) => r.id == reserva.id);
    if (index == -1) {
      throw StateError('Reserva com id ${reserva.id} não encontrada.');
    }
    _reservas[index] = reserva;
    return reserva;
  }

  @override
  Future<void> excluir(String id) async {
    _reservas.removeWhere((reserva) => reserva.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _reservas.fold<int>(
      0,
      (max, r) => int.tryParse(r.id) != null && int.parse(r.id) > max
          ? int.parse(r.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
