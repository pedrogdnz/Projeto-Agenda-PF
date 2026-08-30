import 'package:agendapf/data/models/data_bloqueada_model.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';
import 'package:agendapf/data/services/abstract/data_bloqueada_source.dart';

class FakeDataBloqueadaService implements DataBloqueadaService {
  final List<DataBloqueada> _datasBloqueadas = [
    DataBloqueada(
      id: '1',
      data: DateTime(2026, 9, 7),
      motivo: MotivoBloqueio.feriados, // Independência do Brasil
    ),
    DataBloqueada(
      id: '2',
      data: DateTime(2026, 10, 12),
      motivo: MotivoBloqueio.feriados, // N. Sra. Aparecida
    ),
  ];

  @override
  Future<List<DataBloqueada>> buscarTodas() async {
    return List.unmodifiable(_datasBloqueadas);
  }

  @override
  Future<DataBloqueada?> buscarPorId(String id) async {
    for (final data in _datasBloqueadas) {
      if (data.id == id) return data;
    }
    return null;
  }

  @override
  Future<DataBloqueada> criar(DataBloqueada dataBloqueada) async {
    final novaData = dataBloqueada.copyWith(id: _gerarProximoId());
    _datasBloqueadas.add(novaData);
    return novaData;
  }

  @override
  Future<DataBloqueada> atualizar(DataBloqueada dataBloqueada) async {
    final index = _datasBloqueadas.indexWhere((d) => d.id == dataBloqueada.id);
    if (index == -1) {
      throw StateError(
        'DataBloqueada com id ${dataBloqueada.id} não encontrada.',
      );
    }
    _datasBloqueadas[index] = dataBloqueada;
    return dataBloqueada;
  }

  @override
  Future<void> excluir(String id) async {
    _datasBloqueadas.removeWhere((data) => data.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _datasBloqueadas.fold<int>(
      0,
      (max, d) => int.tryParse(d.id) != null && int.parse(d.id) > max
          ? int.parse(d.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
