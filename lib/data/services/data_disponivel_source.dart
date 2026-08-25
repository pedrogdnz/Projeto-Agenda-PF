import 'package:agendapf/data/models/data_disponivel_model.dart';

abstract class DataDisponivelService {
  Future<List<DataDisponivel>> buscarTodas();
}