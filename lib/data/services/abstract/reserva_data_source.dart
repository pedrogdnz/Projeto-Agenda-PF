import 'package:agendapf/data/models/reserva_model.dart';

abstract class ReservaService {
  Future<List<Reserva>> buscarTodas();
  Future<Reserva?> buscarPorId(String id);
  Future<Reserva> criar(Reserva reserva);
  Future<Reserva> atualizar(Reserva reserva);
  Future<void> excluir(String id);
}