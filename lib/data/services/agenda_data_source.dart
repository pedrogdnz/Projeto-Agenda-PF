import 'package:agendapf/data/models/data_bloqueada_model.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';

abstract class DataBloqueadaService {
  /// Retorna todos os dias que o administrador bloqueou (RN05).
  Future<List<DataBloqueada>> buscarTodas();
}

abstract class HorarioService {
  /// Retorna o catálogo fixo de horários (o mesmo para todo dia aberto).
  Future<List<Horario>> buscarTodos();
}

abstract class ReservaService {
  /// Retorna as reservas já feitas em um dia específico, para saber quais
  /// horários daquele dia já estão ocupados.
  Future<List<Reserva>> buscarPorData(DateTime data);
}
