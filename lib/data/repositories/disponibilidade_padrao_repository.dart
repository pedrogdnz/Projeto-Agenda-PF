import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart'
    show HorarioInvalidoException;
import 'package:agendapf/data/services/abstract/disponibilidade_padrao_data_source.dart';
import 'package:agendapf/data/services/abstract/horario_data_source.dart';

class DisponibilidadePadraoRepository {
  // Catálogo padrão de horários do laboratório (início, fim).
  static const List<(String, String)> _horariosPadrao = [
    ('07:15', '08:05'),
    ('08:05', '08:55'),
    ('08:55', '09:45'),
    ('10:05', '10:55'),
    ('10:55', '11:45'),
    ('11:45', '12:35'),
    ('12:35', '13:15'),
    ('13:15', '14:05'),
    ('14:05', '14:55'),
    ('14:55', '15:45'),
    ('16:05', '16:55'),
    ('16:55', '17:45'),
    ('17:45', '18:35'),
  ];

  List<Horario> _gerarHorariosPadrao() {
    return [
      for (final (inicio, fim) in _horariosPadrao)
        Horario(
          // Id fixo: se dois dispositivos criarem ao mesmo tempo,
          // sobrescrevem o mesmo documento em vez de duplicar.
          id: 'h${inicio.replaceAll(':', '')}',
          horaInicial: inicio,
          horaFinal: fim,
        ),
    ];
  }

  final DisponibilidadePadraoService _disponibilidadeService;
  final HorarioService _horarioService;

  const DisponibilidadePadraoRepository({
    required DisponibilidadePadraoService disponibilidadeService,
    required HorarioService horarioService,
  }) : _disponibilidadeService = disponibilidadeService,
       _horarioService = horarioService;

  DisponibilidadePadraoService get disponibilidadeService =>
      _disponibilidadeService;

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
