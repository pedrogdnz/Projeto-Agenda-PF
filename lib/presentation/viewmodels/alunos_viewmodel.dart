
import 'package:flutter/material.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart'
    show ReservaComHorario;

class AlunoDetalhesViewModel extends ChangeNotifier {
  final String alunoId;
  final AlunoRepository _alunoRepository;
  final AgendaRepository _agendaRepository;

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();
  final emailController = TextEditingController();
  final novaSenhaController = TextEditingController();

  AlunoDetalhesViewModel({
    required this.alunoId,
    required AlunoRepository alunoRepository,
    required AgendaRepository agendaRepository,
  }) : _alunoRepository = alunoRepository,
       _agendaRepository = agendaRepository;

  bool _carregando = true;
  Aluno? _aluno;
  List<ReservaComHorario> _reservas = [];

  bool _editando = false;
  bool _salvando = false;
  bool _excluindo = false;
  bool _excluido = false;
  String? _erro;

  bool get carregando => _carregando;
  Aluno? get aluno => _aluno;
  List<ReservaComHorario> get reservas => _reservas;
  bool get editando => _editando;
  bool get salvando => _salvando;
  bool get excluindo => _excluindo;
  bool get excluido => _excluido;
  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _aluno = await _alunoRepository.buscarPorId(alunoId);

    final todasReservas = await _agendaRepository.reservaService
        .buscarTodas();
    final horarios = await _agendaRepository.horarioService.buscarTodos();
    final horariosPorId = {for (final h in horarios) h.id: h};

    _reservas =
        todasReservas
            .where((r) => r.alunoId == alunoId)
            .map(
              (r) => ReservaComHorario(
                reserva: r,
                horario: horariosPorId[r.horarioId],
              ),
            )
            .toList()
          ..sort((a, b) => b.reserva.dataReserva.compareTo(a.reserva.dataReserva));

    _carregando = false;
    notifyListeners();
  }

  void iniciarEdicao() {
    final atual = _aluno;
    if (atual == null) return;

    nomeController.text = atual.nome;
    matriculaController.text = atual.matricula;
    emailController.text = atual.email;
    novaSenhaController.clear();

    _editando = true;
    _erro = null;
    notifyListeners();
  }

  void cancelarEdicao() {
    _editando = false;
    _erro = null;
    notifyListeners();
  }

  String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o nome';
    return null;
  }

  String? validateMatricula(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a matrícula';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    if (!value.contains('@')) return 'E-mail inválido';
    return null;
  }

  /// Campo opcional: só valida se o administrador digitou algo.
  String? validateNovaSenha(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 6) {
      return 'A nova senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<bool> salvarEdicao() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      _aluno = await _alunoRepository.atualizar(
        id: alunoId,
        nome: nomeController.text,
        matricula: matriculaController.text,
        email: emailController.text,
        novaSenha: novaSenhaController.text,
      );
      _editando = false;
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  Future<bool> excluirAluno() async {
    _excluindo = true;
    _erro = null;
    notifyListeners();

    try {
      await _alunoRepository.excluir(alunoId);
      _excluido = true;
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _excluindo = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
  }

  @override
  void dispose() {
    nomeController.dispose();
    matriculaController.dispose();
    emailController.dispose();
    novaSenhaController.dispose();
    super.dispose();
  }
}
