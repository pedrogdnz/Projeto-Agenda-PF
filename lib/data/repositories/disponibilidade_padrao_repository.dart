import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart'
show HorarioInvalidoException;
import 'package:agendapf/data/services/abstract/disponibilidade_padrao_data_source.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';

class DisponibilidadePadraoRepository {
  // Catálogo padrão de horários: blocos de 50 min entre 07:15 e 18:30.
  // Só entram blocos que TERMINAM até o limite (o último é 17:15–18:05).
  // Para incluir o bloco 18:05–18:55, aumente o limite para 18 * 60 + 55.
  static const int _inicioMinutos = 7 * 60 + 15;
  static const int _limiteMinutos = 18 * 60 + 30;
  static const int _duracaoMinutos = 50;

  final DisponibilidadePadraoService _disponibilidadeService;
  final HorarioService _horarioService;

  const DisponibilidadePadraoRepository({
    required DisponibilidadePadraoService disponibilidadeService,
    required HorarioService horarioService,
  }) : _disponibilidadeService = disponibilidadeService,
       _horarioService = horarioService;

  DisponibilidadePadraoService get disponibilidadeService =>
      _disponibilidadeService;

  /// Devolve o catálogo de horários. Se a coleção `horarios` estiver vazia,
  /// cria o catálogo padrão (isso só acontece no fluxo do admin, que é
  /// quem tem permissão de escrita nas regras do Firestore).
  Future<List<Horario>> buscarHorarios() async {
    var horarios = await _horarioService.buscarTodos();

    if (horarios.isEmpty) {
      for (final horario in _gerarHorariosPadrao()) {
        await _horarioService.criar(horario);
      }
      horarios = await _horarioService.buscarTodos();
    }

    return List.of(horarios)
      ..sort((a, b) => a.horaInicial.compareTo(b.horaInicial));
  }

  List<Horario> _gerarHorariosPadrao() {
    String hhmm(int minutos) {
      final h = (minutos ~/ 60).toString().padLeft(2, '0');
      final m = (minutos % 60).toString().padLeft(2, '0');
      return '$h:$m';
    }

    final lista = <Horario>[];
    for (
      var inicio = _inicioMinutos;
      inicio + _duracaoMinutos <= _limiteMinutos;
      inicio += _duracaoMinutos
    ) {
      final horaInicial = hhmm(inicio);
      lista.add(
        Horario(
          // Id fixo: se dois dispositivos criarem ao mesmo tempo,
          // sobrescrevem o mesmo documento em vez de duplicar.
          id: 'h${horaInicial.replaceAll(':', '')}',
          horaInicial: horaInicial,
          horaFinal: hhmm(inicio + _duracaoMinutos),
        ),
      );
    }
    return lista;
  }

  Future<List<DisponibilidadePadrao>> buscarSemana() async {
    final registros = await _disponibilidadeService.buscarTodas();
    final porDia = {for (final r in registros) r.diaSemana: r};

    return [
      for (final dia in DiaSemana.values)
        porDia[dia] ?? DisponibilidadePadrao(id: '', diaSemana: dia),
    ];
  }

  Future<DisponibilidadePadrao> buscarPorDia(DiaSemana dia) async {
    final existente = await _disponibilidadeService.buscarPorDia(dia);
    return existente ?? DisponibilidadePadrao(id: '', diaSemana: dia);
  }

  /// Ids dos horários liberados pela Regra Geral para a data informada.
  Future<List<String>> horarioIdsPara(DateTime data) async {
    final disponibilidade = await buscarPorDia(DiaSemana.fromData(data));
    return disponibilidade.horarioIds;
  }

  Future<DisponibilidadePadrao> atualizarHorarios({
    required DiaSemana diaSemana,
    required List<String> horarioIds,
  }) async {
    final horarios = await buscarHorarios();
    final idsValidos = {for (final h in horarios) h.id};
    final idsSolicitados = horarioIds.toSet();

    if (!idsValidos.containsAll(idsSolicitados)) {
      throw const HorarioInvalidoException();
    }

    final ordenados = List<String>.unmodifiable([
      for (final h in horarios)
        if (idsSolicitados.contains(h.id)) h.id,
    ]);

    final existente = await _disponibilidadeService.buscarPorDia(diaSemana);
    if (existente == null) {
      return _disponibilidadeService.criar(
        DisponibilidadePadrao(
          // Id = nome do dia ("segunda", "terca"...): nunca duplica.
          id: diaSemana.name,
          diaSemana: diaSemana,
          horarioIds: ordenados,
        ),
      );
    }

    return _disponibilidadeService.atualizar(
      existente.copyWith(horarioIds: ordenados),
    );
  }
}