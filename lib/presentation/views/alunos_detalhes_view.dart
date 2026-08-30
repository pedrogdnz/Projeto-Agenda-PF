import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/presentation/viewmodels/aluno_detalhes_viewmodel.dart';
import 'package:agendapf/presentation/widgets/empty_state_view.dart';
import 'package:agendapf/presentation/widgets/text_field.dart';

class AlunoDetalhesPage extends StatefulWidget {
  final String alunoId;
  final AlunoRepository alunoRepository;
  final AgendaRepository agendaRepository;

  const AlunoDetalhesPage({
    super.key,
    required this.alunoId,
    required this.alunoRepository,
    required this.agendaRepository,
  });

  @override
  State<AlunoDetalhesPage> createState() => _AlunoDetalhesPageState();
}

class _AlunoDetalhesPageState extends State<AlunoDetalhesPage> {
  late final AlunoDetalhesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AlunoDetalhesViewModel(
      alunoId: widget.alunoId,
      alunoRepository: widget.alunoRepository,
      agendaRepository: widget.agendaRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregar();
  }

  void _handleViewModelChange() {
    final erro = _viewModel.erro;
    if (erro != null) {
      _viewModel.limparErro();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
      });
    }

    if (_viewModel.excluido) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Aluno'),
        content: Text(
          'Tem certeza de que deseja excluir ${_viewModel.aluno?.nome ?? 'este aluno'}? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _viewModel.excluirAluno();
            },
            child: const Text(
              'Sim, excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aluno = _viewModel.aluno;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do Aluno',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: _viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : aluno == null
          ? const EmptyStateView(
              icon: Icons.person_off_outlined,
              message: 'Aluno não encontrado',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCabecalho(aluno),
                    const SizedBox(height: 20),
                    _viewModel.editando
                        ? _buildFormularioEdicao()
                        : _buildInformacoes(aluno),
                    const SizedBox(height: 28),
                    const Text(
                      'Reservas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildListaReservas(),
                    const SizedBox(height: 28),
                    if (!_viewModel.editando) _buildBotoesAcao(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCabecalho(Aluno aluno) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          child: Text(
            aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                aluno.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Matrícula: ${aluno.matricula}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformacoes(Aluno aluno) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLinha(label: 'Nome', valor: aluno.nome),
          const Divider(height: 20),
          _InfoLinha(label: 'Matrícula', valor: aluno.matricula),
          const Divider(height: 20),
          _InfoLinha(label: 'E-mail', valor: aluno.email),
          const Divider(height: 20),
          _InfoLinha(
            label: 'Cadastrado em',
            valor: DateFormat('dd/MM/yyyy').format(aluno.criadoEm),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioEdicao() {
    return Form(
      key: _viewModel.formKey,
      child: Column(
        children: [
          CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.nomeController,
            label: 'Nome',
            validator: _viewModel.validateNome,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.emailController,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            validator: _viewModel.validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.matriculaController,
            label: 'Matrícula',
            keyboardType: TextInputType.number,
            validator: _viewModel.validateMatricula,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            requiredField: false,
            isPassword: true,
            controller: _viewModel.novaSenhaController,
            label: 'Nova senha (opcional)',
            validator: _viewModel.validateNovaSenha,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Deixe em branco para manter a senha atual.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _viewModel.salvando
                      ? null
                      : _viewModel.cancelarEdicao,
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _viewModel.salvando
                      ? null
                      : _viewModel.salvarEdicao,
                  child: _viewModel.salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Salvar',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaReservas() {
    if (_viewModel.reservas.isEmpty) {
      return const EmptyStateView(
        icon: Icons.event_busy,
        message: 'Este aluno ainda não possui reservas',
      );
    }

    return Column(
      children: _viewModel.reservas.map((item) {
        final reserva = item.reserva;
        final horario = item.horario;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${reserva.dataReserva.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMM',
                        'pt_BR',
                      ).format(reserva.dataReserva).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horario != null
                          ? '${horario.horaInicial} às ${horario.horaFinal}'
                          : 'Horário não encontrado',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Fundo: ${reserva.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (reserva.descricao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          reserva.descricao,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBotoesAcao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _viewModel.excluindo ? null : _confirmarExclusao,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _viewModel.excluindo
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text('Excluir'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _viewModel.excluindo ? null : _viewModel.iniciarEdicao,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text('Editar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final String label;
  final String valor;

  const _InfoLinha({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
