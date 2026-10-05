
import 'package:flutter/material.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/models/reserva_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart'
    show TipoFiltroReserva;

class ReservaDoAluno {
  final Reserva reserva;
  final Horario? horario;
  final Aluno? aluno;

  const ReservaDoAluno({required this.reserva, this.horario, this.aluno});
}

class AdminReservasViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository;
  final AlunoRepository _alunoRepository;

  AdminReservasViewModel({
    required AgendaRepository agendaRepository,
    required AlunoRepository alunoRepository,
  }) : _agendaRepository = agendaRepository,
       _alunoRepository = alunoRepository;

  bool _carregando = true;
  List<ReservaDoAluno> _reservas = [];
  TipoFiltroReserva _filtroAtual = TipoFiltroReserva.ativas;
  String? _erro;
  String? _mensagemInfo;

  bool get carregando => _carregando;
  TipoFiltroReserva get filtroAtual => _filtroAtual;
  String? get erro => _erro;
  String? get mensagemInfo => _mensagemInfo;

  /// Novas: da mais próxima para a mais distante.
  /// Antigas: da mais recente para a mais antiga.
  List<ReservaDoAluno> get reservasFiltradas {
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final novas = _filtroAtual == TipoFiltroReserva.ativas;

    final lista = _reservas
        .where(
          (r) => novas
              ? !r.reserva.dataReserva.isBefore(inicioHoje)
              : r.reserva.dataReserva.isBefore(inicioHoje),
        )
        .toList();

    lista.sort((a, b) {
      final porData = a.reserva.dataReserva.compareTo(b.reserva.dataReserva);
      final cmp = porData != 0
          ? porData
          : (a.horario?.horaInicial ?? '').compareTo(
              b.horario?.horaInicial ?? '',
            );
      return novas ? cmp : -cmp;
    });

    return lista;
  }

  void alterarFiltro(TipoFiltroReserva novoFiltro) {
    if (_filtroAtual == novoFiltro) return;
    _filtroAtual = novoFiltro;
    notifyListeners();
  }

  Future<void> carregarReservas() async {
    _carregando = true;
    notifyListeners();

    try {
      final reservas = await _agendaRepository.reservaService.buscarTodas();
      final horarios = await _agendaRepository.horarioService.buscarTodos();
      final alunos = await _alunoRepository.buscarTodos();

      final horariosPorId = {for (final h in horarios) h.id: h};
      final alunosPorId = {for (final a in alunos) a.id: a};

      _reservas = reservas
          .map(
            (r) => ReservaDoAluno(
              reserva: r,
              horario: horariosPorId[r.horarioId],
              aluno: alunosPorId[r.alunoId],
            ),
          )
          .toList();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirReserva(String reservaId) async {
    _erro = null;
    try {
      await _agendaRepository.excluirReservaComoAdmin(reservaId);
      await carregarReservas();
      _mensagemInfo = 'Reserva removida.';
      notifyListeners();
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  void limparErro() => _erro = null;
  void limparMensagemInfo() => _mensagemInfo = null;
}
