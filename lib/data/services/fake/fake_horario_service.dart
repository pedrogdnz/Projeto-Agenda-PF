import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';

//TODO - essa lista é const, então _horarios.add(...) em criar() já daria erro em runtime

class FakeHorarioService implements HorarioService {
  final List<Horario> _horarios = const [
    Horario(id: '1', horaInicial: '08:00', horaFinal: '09:00'),
    Horario(id: '2', horaInicial: '09:00', horaFinal: '10:00'),
    Horario(id: '3', horaInicial: '10:00', horaFinal: '11:00'),
    Horario(id: '4', horaInicial: '11:00', horaFinal: '12:00'),
    Horario(id: '5', horaInicial: '12:00', horaFinal: '13:00'),
    Horario(id: '6', horaInicial: '13:00', horaFinal: '14:00'),
    Horario(id: '7', horaInicial: '14:00', horaFinal: '15:00'),
    Horario(id: '8', horaInicial: '15:00', horaFinal: '16:00'),
    Horario(id: '9', horaInicial: '16:00', horaFinal: '17:00'),
    Horario(id: '10', horaInicial: '17:00', horaFinal: '18:00'),
  ];

  @override
  Future<List<Horario>> buscarTodos() async {
    return List.unmodifiable(_horarios);
  }

  @override
  Future<Horario?> buscarPorId(String id) async {
    for (final horario in _horarios) {
      if (horario.id == id) return horario;
    }
    return null;
  }

  @override
  Future<Horario> criar(Horario horario) async {
    final novoHorario = horario.copyWith(id: _gerarProximoId());
    _horarios.add(novoHorario);
    return novoHorario;
  }

  @override
  Future<Horario> atualizar(Horario horario) async {
    final index = _horarios.indexWhere((h) => h.id == horario.id);
    if (index == -1) {
      throw StateError('Horario com id ${horario.id} não encontrado.');
    }
    _horarios[index] = horario;
    return horario;
  }

  @override
  Future<void> excluir(String id) async {
    _horarios.removeWhere((horario) => horario.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _horarios.fold<int>(
      0,
      (max, h) => int.tryParse(h.id) != null && int.parse(h.id) > max
          ? int.parse(h.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
