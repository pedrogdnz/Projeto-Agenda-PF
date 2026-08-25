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
}
