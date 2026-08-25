import 'package:agendapf/data/models/data_bloqueada_model.dart';
import 'package:agendapf/data/services/abstract/data_bloqueada_source.dart';

class FakeDataBloqueadaService implements DataBloqueadaService {
  final List<DataBloqueada> _datasBloqueadas = [
    DataBloqueada(id: '1', data: DateTime(2026, 9, 7)),
    DataBloqueada(id: '2', data: DateTime(2026, 10, 12)),
  ];

  @override
  Future<List<DataBloqueada>> buscarTodas() async {
    return List.unmodifiable(_datasBloqueadas);
  }
}
