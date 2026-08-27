import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';
import 'package:agendapf/data/services/abstract/data_bloqueada_source.dart';
import 'package:agendapf/data/services/abstract/reserva_data_source.dart';

/// Um horário do dia, com a disponibilidade calculada PARA CADA FUNDO
/// separadamente — o mesmo horário pode estar ocupado no fundo preto e
/// livre no branco ao mesmo tempo.
class HorarioDoDia {
  final Horario horario;
  final Map<CorFundoHorario, bool> disponibilidadePorFundo;

  const HorarioDoDia({
    required this.horario,
    required this.disponibilidadePorFundo,
  });

  bool disponivelPara(CorFundoHorario fundo) =>
      disponibilidadePorFundo[fundo] ?? true;

  bool get algumFundoDisponivel =>
      disponibilidadePorFundo.values.any((disponivel) => disponivel);
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
    this.mensagem =
        'Este horário já está reservado para este fundo nesta data.',
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

    // Fundos já ocupados por horário, só considerando reservas do dia.
    final fundosOcupadosPorHorario = <String, Set<CorFundoHorario>>{};
    for (final reserva in reservas) {
      if (_normalizarData(reserva.dataReserva) != diaNormalizado) continue;
      fundosOcupadosPorHorario
          .putIfAbsent(reserva.horarioId, () => {})
          .add(reserva.corFundo);
    }

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
          final fundosOcupados =
              fundosOcupadosPorHorario[horario.id] ?? const {};
          final disponibilidade = {
            for (final fundo in CorFundoHorario.values)
              fundo: !fundosOcupados.contains(fundo),
          };
          return HorarioDoDia(
            horario: horario,
            disponibilidadePorFundo: disponibilidade,
          );
        })
        .toList();
  }

  /// Cria uma [Reserva] vinculando o [alunoId] a um [Horario] pré-cadastrado,
  /// numa [data] específica, com o [corFundo] e a [descricao] escolhidos
  /// pelo próprio aluno. A checagem de conflito é por (horário, data, fundo)
  /// — não por (horário, data) — para permitir que dois alunos ocupem o
  /// mesmo horário no mesmo dia, desde que em fundos diferentes.
  Future<Reserva> criarReserva({
    required String alunoId,
    required String horarioId,
    required DateTime data,
    required CorFundoHorario corFundo,
    String descricao = '',
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
          r.corFundo == corFundo &&
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
        corFundo: corFundo,
        descricao: descricao,
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
