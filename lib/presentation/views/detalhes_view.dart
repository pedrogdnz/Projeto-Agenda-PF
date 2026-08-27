// lib/presentation/views/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/presentation/viewmodels/detalhes_viewmodel.dart';
import 'package:agendapf/presentation/views/reservas_view.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key, required this.data});

  final DateTime data;

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  late final DetalhesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DetalhesViewModel(data: widget.data);
    _viewModel.addListener(_handleViewModelChange);
  }

  void _handleViewModelChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selecionarHoraInicial() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: _viewModel.horaInicialSelecionada ?? TimeOfDay.now(),
    );

    if (horario != null) {
      _viewModel.selecionarHoraInicial(horario);
    }
  }

  Future<void> _selecionarHoraFinal() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: _viewModel.horaFinalSelecionada ?? TimeOfDay.now(),
    );

    if (horario != null) {
      _viewModel.selecionarHoraFinal(horario);
    }
  }

  void _confirmar() {
    final erro = _viewModel.validarSelecao();

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Reservas()),
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

            Row(
              children: [
                Expanded(
                  child: _CampoHorario(
                    label: 'Início',
                    horario: _viewModel.horaInicialSelecionada,
                    onTap: _selecionarHoraInicial,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CampoHorario(
                    label: 'Fim',
                    horario: _viewModel.horaFinalSelecionada,
                    onTap: _selecionarHoraFinal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Cor do fundo:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _viewModel.corFundoSelecionada == CorFundoHorario.preto
                        ? Colors.black
                        : null,
                  ),
                  onPressed: () {
                    _viewModel.selecionarCorFundo(CorFundoHorario.preto);
                  },
                  child: Text(
                    "Preto",
                    style: TextStyle(
                      color:
                          _viewModel.corFundoSelecionada ==
                              CorFundoHorario.preto
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _viewModel.corFundoSelecionada == CorFundoHorario.branco
                        ? Colors.grey.shade300
                        : null,
                  ),
                  onPressed: () {
                    _viewModel.selecionarCorFundo(CorFundoHorario.branco);
                  },
                  child: const Text("Branco"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: const [
                Text(
                  "Descrição ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("*Opcional", style: TextStyle(fontSize: 12)),
              ],
            ),

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
                onPressed: _confirmar,
                child: const Text(
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

/// Campo reutilizável para selecionar um horário (inicial ou final),
/// exibido como um InputDecorator clicável que abre o [showTimePicker].
class _CampoHorario extends StatelessWidget {
  final String label;
  final TimeOfDay? horario;
  final VoidCallback onTap;

  const _CampoHorario({
    required this.label,
    required this.horario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(horario == null ? 'Selecionar' : horario!.format(context)),
      ),
    );
  }
}
//TODO - É RELATIVAMENTE DIFÍCIL ESCOLHER UMA HORA INTEIRA - TIPO DAS 17 AS 18. ELES VÃO PEGAR HORÁRIOS QUEBRADOS
//TODO - ALÉM DISSO, QUANDO O ALUNO FAZ UMA RESERVA, ELE AUTOMATICAMENTE VAI PARA A TELA DE RESERVAS (ALGO OK), MAS QUANDO VOLTA, RETORNA A TELA DE DETALHES
//TODO - NÃO ESTÁ APARECENDO QUAIS HORÁRIOS NÃO ESTÃO DISPONÍVEIS.