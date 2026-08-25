import 'package:agendapf/data/models/horario_model.dart';

class FakeHorarioService implements HorarioService {
  @override
  Future<List<Horario>> buscarTodos() async {
    return [
      Horario(
        id: '1',
        horaInicial: '08:00',
        horaFinal: '09:00',
        corFundo: CorFundoHorario.branco,
      ),
      Horario(
        id: '2',
        horaInicial: '09:00',
        horaFinal: '10:00',
        corFundo: CorFundoHorario.branco,
      ),
      Horario(
        id: '3',
        horaInicial: '10:00',
        horaFinal: '11:00',
        corFundo: CorFundoHorario.preto,
      ),
      Horario(
        id: '4',
        horaInicial: '14:00',
        horaFinal: '15:00',
        corFundo: CorFundoHorario.branco,
      ),
    ];
  }
}