import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';
import 'package:agendapf/data/services/abstract/data_bloqueada_source.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';

class HorarioDoDia {
  final Horario horario;
  final bool disponivel;

  const HorarioDoDia({required this.horario, required this.disponivel});
}

class DataIndisponivelException implements Exception {
  final String mensagem;
  const DataIndisponivelException([
    this.mensagem = 'Esta data não está disponível para reserva.',
  ]);

  @override
  String toString() => mensagem;
}

class HorarioInvalidoException implements Exception {
  final String mensagem;
  const HorarioInvalidoException([this.mensagem = 'Horário inválido.']);

  @override
  String toString() => mensagem;
}

class HorarioIndisponivelException implements Exception {
  final String mensagem;
  const HorarioIndisponivelException([
    this.mensagem = 'Este horário já está reservado para esta data.',
  ]);

  @override
  String toString() => mensagem;
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

  /// Expostos para que outras camadas (ex.: ReservasViewModel) possam
  /// reutilizar exatamente a mesma instância de serviço — e assim enxergar
  /// as mesmas reservas em memória — em vez de criar uma cópia separada do
  /// serviço fake (o que fazia reservas "sumirem" entre telas).
  HorarioService get horarioService => _horarioService;
  ReservaService get reservaService => _reservaService;

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
    final reservas = await _reservaService.buscarTodas();

    final idsReservadosNoDia = reservas
        .where((r) => _normalizarData(r.dataReserva) == diaNormalizado)
        .map((r) => r.horarioId)
        .toSet();

    final agora = DateTime.now();
    final ehHoje = _normalizarData(agora) == diaNormalizado;

    return horarios
        .where((horario) {
          if (!ehHoje) return true;
          final inicio = _combinarDataEHora(
            diaNormalizado,
            horario.horaInicial,
          );
          return inicio.isAfter(agora);
        })
        .map((horario) {
          final reservado = idsReservadosNoDia.contains(horario.id);
          return HorarioDoDia(horario: horario, disponivel: !reservado);
        })
        .toList();
  }

  /// Cria uma [Reserva] vinculando o [alunoId] a um [Horario] pré-cadastrado
    Future<Reserva> criarReserva({
    required String alunoId,
    required String horarioId,
    required DateTime data,
  }) async {
    final diaNormalizado = _normalizarData(data);
    final diasBloqueados = await buscarDiasBloqueados();

    if (!diaSelecionavel(diaNormalizado, diasBloqueados)) {
      throw const DataIndisponivelException();
    }

    final horario = await _horarioService.buscarPorId(horarioId);
    if (horario == null) {
      throw const HorarioInvalidoException();
    }

    final reservas = await _reservaService.buscarTodas();
    final jaReservado = reservas.any(
      (r) =>
          r.horarioId == horarioId &&
          _normalizarData(r.dataReserva) == diaNormalizado,
    );

    if (jaReservado) {
      throw const HorarioIndisponivelException();
    }

    return _reservaService.criar(
      Reserva(
        id: '', // O SERVICE QUE CRIA O ID
        alunoId: alunoId,
        horarioId: horarioId,
        dataReserva: diaNormalizado,
      ),
    );
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
