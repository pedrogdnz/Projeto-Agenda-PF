import 'package:agendapf/data/models/data_disponivel_model.dart';
import 'package:agendapf/data/services/abstract/data_disponivel_source.dart';

class FakeDataDisponivelService implements DataDisponivelService {
  final List<DataDisponivel> _datasDisponiveis = [
    DataDisponivel(id: '1', data: DateTime(2026, 8, 25)),
    DataDisponivel(id: '2', data: DateTime(2026, 8, 26)),
    DataDisponivel(id: '3', data: DateTime(2026, 8, 27)),
  ];

  @override
  Future<List<DataDisponivel>> buscarTodas() async {
    return List.unmodifiable(_datasDisponiveis);
  }
}
