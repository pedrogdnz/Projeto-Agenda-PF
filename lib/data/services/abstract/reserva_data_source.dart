import 'package:agendapf/data/models/reserva_model.dart';

abstract class ReservaService {
  Future<List<Reserva>> buscarTodas();
}