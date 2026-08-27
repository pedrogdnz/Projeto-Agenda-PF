import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/presentation/viewmodels/detalhes_viewmodel.dart';
import 'package:agendapf/presentation/views/reservas_view.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({
    super.key,
    required this.data,
    required this.alunoId,
    required this.agendaRepository,
  });

  final DateTime data;
  final String alunoId;
  final AgendaRepository agendaRepository;

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  late final DetalhesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DetalhesViewModel(
      data: widget.data,
      alunoId: widget.alunoId,
      agendaRepository: widget.agendaRepository,
    );
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarHorarios();
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

  Future<void> _confirmar() async {
    final sucesso = await _viewModel.confirmarReserva();
    if (!mounted || !sucesso) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Reservas(
          alunoId: widget.alunoId,
          agendaRepository: widget.agendaRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Sua Seleção",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_rounded),
              ],
            ),

            const Text("Confirme sua reserva"),

            Text(
              '${_viewModel.data.day}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            Text(
              DateFormat('EEEE', 'pt_BR').format(_viewModel.data),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20),

            const Text(
              "Horário:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _viewModel.carregandoHorarios
                  ? const Center(child: CircularProgressIndicator())
                  : _viewModel.horariosDoDia.isEmpty
                  ? const _SemHorariosView()
                  : ListView.separated(
                      itemCount: _viewModel.horariosDoDia.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _viewModel.horariosDoDia[index];
                        final selecionado =
                            _viewModel.horarioSelecionado == item.horario;

                        return _HorarioTile(
                          item: item,
                          selecionado: selecionado,
                          onTap: () => _viewModel.selecionarHorario(item),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Text(
                  "Descrição ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("*Opcional", style: TextStyle(fontSize: 12)),
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
                style: TextButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _viewModel.confirmando ? null : _confirmar,
                child: _viewModel.confirmando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um horário pré-cadastrado (RN04) que o aluno pode selecionar. Horários
/// já reservados naquele dia aparecem desabilitados ("Ocupado").
class _HorarioTile extends StatelessWidget {
  final HorarioDoDia item;
  final bool selecionado;
  final VoidCallback onTap;

  const _HorarioTile({
    required this.item,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final horario = item.horario;
    final disponivel = item.disponivel;

    return Opacity(
      opacity: disponivel ? 1 : 0.5,
      child: InkWell(
        onTap: disponivel ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selecionado ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selecionado ? Colors.black : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: selecionado ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${horario.horaInicial} às ${horario.horaFinal}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selecionado ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (horario.descricao.isNotEmpty)
                      Text(
                        horario.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: selecionado
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              _CorFundoBadge(cor: horario.corFundo, destacado: selecionado),
              if (!disponivel) ...[
                const SizedBox(width: 8),
                Text(
                  'Ocupado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selecionado ? Colors.white70 : Colors.red.shade300,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Exibe a [CorFundoHorario] do horário — atributo fixo do laboratório,
/// não uma escolha do aluno (por isso não há mais botões "Preto"/"Branco").
class _CorFundoBadge extends StatelessWidget {
  final CorFundoHorario cor;
  final bool destacado;

  const _CorFundoBadge({required this.cor, required this.destacado});

  @override
  Widget build(BuildContext context) {
    final ehPreto = cor == CorFundoHorario.preto;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ehPreto ? Colors.black : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: destacado ? Border.all(color: Colors.white70) : null,
      ),
      child: Text(
        ehPreto ? 'Preto' : 'Branco',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ehPreto ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _SemHorariosView extends StatelessWidget {
  const _SemHorariosView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Nenhum horário disponível para este dia',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
