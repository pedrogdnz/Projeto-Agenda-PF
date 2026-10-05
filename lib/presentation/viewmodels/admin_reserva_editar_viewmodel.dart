import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/presentation/viewmodels/admin_reserva_editar_viewmodel.dart';
import 'package:agendapf/presentation/viewmodels/admin_reservas_viewmodel.dart'
    show ReservaDoAluno;
import 'package:agendapf/presentation/widgets/empty_state_view.dart';
import 'package:agendapf/presentation/widgets/horario_tile.dart';

class AdminReservaEditarPage extends StatefulWidget {
  final ReservaDoAluno item;
  final AgendaRepository agendaRepository;

  const AdminReservaEditarPage({
    super.key,
    required this.item,
    required this.agendaRepository,
  });

  @override
  State<AdminReservaEditarPage> createState() => _AdminReservaEditarPageState();
}

class _AdminReservaEditarPageState extends State<AdminReservaEditarPage> {
  late final AdminReservaEditarViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminReservaEditarViewModel(
      item: widget.item,
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
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final agora = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _viewModel.dataInicialParaPicker,
      firstDate: DateTime(agora.year, agora.month, agora.day),
      lastDate: DateTime(agora.year + 1, 12, 31),
      selectableDayPredicate: _viewModel.diaSelecionavel,
    );
    if (escolhida != null) {
      await _viewModel.selecionarData(escolhida);
    }
  }

  Future<void> _salvar() async {
    final sucesso = await _viewModel.salvar();
    if (!mounted || !sucesso) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final nomeAluno = widget.item.aluno?.nome ?? 'Aluno não encontrado';

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
          'Editar Reserva',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: _viewModel.carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeAluno,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Data:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _viewModel.salvando ? null : _escolherData,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: Text(
                          DateFormat(
                            "EEEE, dd/MM/yyyy",
                            'pt_BR',
                          ).format(_viewModel.data),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Fundo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Branco')),
                            selected:
                                _viewModel.fundoSelecionado ==
                                CorFundoHorario.branco,
                            onSelected: (_) => _viewModel.selecionarFundo(
                              CorFundoHorario.branco,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Preto')),
                            selected:
                                _viewModel.fundoSelecionado ==
                                CorFundoHorario.preto,
                            onSelected: (_) => _viewModel.selecionarFundo(
                              CorFundoHorario.preto,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Horário:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _viewModel.carregandoHorarios
                          ? const Center(child: CircularProgressIndicator())
                          : _viewModel.horariosDoDia.isEmpty
                          ? const EmptyStateView(
                              icon: Icons.access_time_outlined,
                              message: 'Nenhum horário disponível neste dia.',
                            )
                          : ListView.separated(
                              itemCount: _viewModel.horariosDoDia.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final horarioDoDia =
                                    _viewModel.horariosDoDia[index];
                                return HorarioTile(
                                  item: horarioDoDia,
                                  fundoSelecionado: _viewModel.fundoSelecionado,
                                  selecionado:
                                      _viewModel.horarioSelecionado ==
                                      horarioDoDia.horario,
                                  onTap: () => _viewModel.selecionarHorario(
                                    horarioDoDia,
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Text(
                          'Descrição ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('*Opcional', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _viewModel.descricaoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: _viewModel.salvando ? null : _salvar,
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
                                'Salvar alterações',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
