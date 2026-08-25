import 'package:agendapf/data/models/data_bloqueada_model.dart';

abstract class DataBloqueadaService {
  Future<List<DataBloqueada>> buscarTodas();
}