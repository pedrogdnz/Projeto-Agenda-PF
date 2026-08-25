import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';

class FakeHorarioService implements HorarioService {
  final List<Horario> _horarios = [
    const Horario(
      id: '1',
      horaInicial: '08:00',
      horaFinal: '09:00',
      corFundo: CorFundoHorario.branco,
      descricao: 'Aula Individual',
    ),
    const Horario(
      id: '2',
      horaInicial: '09:00',
      horaFinal: '10:00',
      corFundo: CorFundoHorario.preto,
      descricao: 'Treino Funcional',
    ),
    const Horario(
      id: '3',
      horaInicial: '10:00',
      horaFinal: '11:00',
      corFundo: CorFundoHorario.branco,
      descricao: 'Avaliação Física',
    ),
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
