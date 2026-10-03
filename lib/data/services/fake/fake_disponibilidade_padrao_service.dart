import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/services/abstract/disponibilidade_padrao_data_source.dart';

class FakeDisponibilidadePadraoService implements DisponibilidadePadraoService {
  // Ids dos horários do FakeHorarioService (08:00–18:00).
  static const List<String> _horariosDiaUtil = [
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
  ];

  final List<DisponibilidadePadrao> _disponibilidades = [
    const DisponibilidadePadrao(
      id: '1',
      diaSemana: DiaSemana.segunda,
      horarioIds: _horariosDiaUtil,
    ),
    const DisponibilidadePadrao(
      id: '2',
      diaSemana: DiaSemana.terca,
      horarioIds: _horariosDiaUtil,
    ),
    const DisponibilidadePadrao(
      id: '3',
      diaSemana: DiaSemana.quarta,
      horarioIds: _horariosDiaUtil,
    ),
    const DisponibilidadePadrao(
      id: '4',
      diaSemana: DiaSemana.quinta,
      horarioIds: _horariosDiaUtil,
    ),
    const DisponibilidadePadrao(
      id: '5',
      diaSemana: DiaSemana.sexta,
      horarioIds: _horariosDiaUtil,
    ),
    const DisponibilidadePadrao(id: '6', diaSemana: DiaSemana.sabado),
    const DisponibilidadePadrao(id: '7', diaSemana: DiaSemana.domingo),
  ];

  @override
  Future<List<DisponibilidadePadrao>> buscarTodas() async {
    return List.unmodifiable(_disponibilidades);
  }

  @override
  Future<DisponibilidadePadrao?> buscarPorId(String id) async {
    for (final item in _disponibilidades) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<DisponibilidadePadrao?> buscarPorDia(DiaSemana diaSemana) async {
    for (final item in _disponibilidades) {
      if (item.diaSemana == diaSemana) return item;
    }
    return null;
  }

  @override
  Future<DisponibilidadePadrao> criar(
    DisponibilidadePadrao disponibilidade,
  ) async {
    final nova = disponibilidade.copyWith(id: _gerarProximoId());
    _disponibilidades.add(nova);
    return nova;
  }

  @override
  Future<DisponibilidadePadrao> atualizar(
    DisponibilidadePadrao disponibilidade,
  ) async {
    final index = _disponibilidades.indexWhere(
      (d) => d.id == disponibilidade.id,
    );
    if (index == -1) {
      throw StateError(
        'DisponibilidadePadrao com id ${disponibilidade.id} não encontrada.',
      );
    }
    _disponibilidades[index] = disponibilidade;
    return disponibilidade;
  }

  @override
  Future<void> excluir(String id) async {
    _disponibilidades.removeWhere((d) => d.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _disponibilidades.fold<int>(
      0,
      (max, d) => int.tryParse(d.id) != null && int.parse(d.id) > max
          ? int.parse(d.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
