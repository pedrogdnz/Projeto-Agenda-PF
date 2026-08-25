import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/services/agenda_data_source.dart';

class HorarioDoDia {
  final Horario horario;
  final bool disponivel;

  const HorarioDoDia({required this.horario, required this.disponivel});
}

class AgendaRepository {
  final DataBloqueadaService _dataBloqueadaService;
  final HorarioService _horarioService;
  final ReservaService _reservaService;

  const AgendaRepository({
    required DataBloqueadaService dataBloqueadaService,
    required HorarioService horarioService,
    required ReservaService reservaService,
  }) : _dataBloqueadaService = dataBloqueadaService,
       _horarioService = horarioService,
       _reservaService = reservaService;

  Future<Set<DateTime>> buscarDiasBloqueados() async {
    final registros = await _dataBloqueadaService.buscarTodas();
    return registros.map((d) => _normalizarData(d.data)).toSet();
  }

  bool diaSelecionavel(DateTime dia, Set<DateTime> diasBloqueados) {
    final hoje = _normalizarData(DateTime.now());
    final diaNormalizado = _normalizarData(dia);

    if (diaNormalizado.isBefore(hoje)) return false; // RN04
    if (diasBloqueados.contains(diaNormalizado)) return false; // RN05

    return true;
  }

  Future<List<HorarioDoDia>> buscarHorariosDoDia(DateTime dia) async {
    final diaNormalizado = _normalizarData(dia);
    final diasBloqueados = await buscarDiasBloqueados();

    if (!diaSelecionavel(diaNormalizado, diasBloqueados)) {
      return const [];
    }

    final horarios = await _horarioService.buscarTodos();
    final reservasDoDia = await _reservaService.buscarPorData(diaNormalizado);
    final idsReservados = reservasDoDia.map((r) => r.horarioId).toSet();

    final agora = DateTime.now();
    final ehHoje = _normalizarData(agora) == diaNormalizado;

    return horarios
        .where((horario) {
          if (!ehHoje) return true;
          final inicio = _combinarDataEHora(
            diaNormalizado,
            horario.horaInicial,
          );
          return inicio.isAfter(agora); // RN04: horário passado não é listado
        })
        .map((horario) {
          final reservado = idsReservados.contains(horario.id);
          return HorarioDoDia(horario: horario, disponivel: !reservado);
        })
        .toList();
  }

  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime _combinarDataEHora(DateTime dia, String horaHHmm) {
    final partes = horaHHmm.split(':');
    final hora = int.parse(partes[0]);
    final minuto = partes.length > 1 ? int.parse(partes[1]) : 0;
    return DateTime(dia.year, dia.month, dia.day, hora, minuto);
  }
}
