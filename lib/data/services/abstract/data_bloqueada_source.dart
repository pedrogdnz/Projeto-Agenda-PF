import 'package:agendapf/data/models/data_bloqueada_model.dart';

abstract class DataBloqueadaService {
  Future<List<DataBloqueada>> buscarTodas();
  Future<DataBloqueada?> buscarPorId(String id);
  Future<DataBloqueada> criar(DataBloqueada dataBloqueada);
  Future<DataBloqueada> atualizar(DataBloqueada dataBloqueada);
  Future<void> excluir(String id);
}
