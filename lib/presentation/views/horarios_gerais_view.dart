// lib/presentation/views/horarios_gerais_view.dart
import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';
import 'package:agendapf/data/repositories/disponibilidade_padrao_repository.dart';
import 'package:agendapf/presentation/viewmodels/disponibilidade_padrao_viewmodel.dart';

class HorariosGeraisPage extends StatefulWidget {
  final DisponibilidadePadraoRepository disponibilidadePadraoRepository;

  const HorariosGeraisPage({
    super.key,
    required this.disponibilidadePadraoRepository,
  });

  @override
  State<HorariosGeraisPage> createState() => _HorariosGeraisPageState();
}

class _HorariosGeraisPageState extends State<HorariosGeraisPage> {
  late final DisponibilidadePadraoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DisponibilidadePadraoViewModel(
      repository: widget.disponibilidadePadraoRepository,
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

    final info = _viewModel.mensagemInfo;
    if (info != null) {
      _viewModel.limparMensagemInfo();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(info)));
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

  @override
  Widget build(BuildContext context) {
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
          'Horários Gerais',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _viewModel.carregando
            ? const Center(child: CircularProgressIndicator())
            : _viewModel.horarios.isEmpty
            ? _buildSemHorarios()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    'Defina os horários padrão de cada dia da semana. '
                    'Dias sem horários ficam indisponíveis para reserva.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  for (final dia in DiaSemana.values) _buildDia(dia),
                ],
              ),
      ),
    );
  }

  Widget _buildSemHorarios() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar os horários.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _viewModel.carregar,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDia(DiaSemana dia) {
    final quantidade = _viewModel.selecionados(dia).length;
    final salvando = _viewModel.salvandoDia == dia;
    final alterado = _viewModel.temAlteracoes(dia);

    return Card(
      key: ValueKey(dia),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          dia.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          quantidade == 0
              ? 'Sem atendimento'
              : '$quantidade horário${quantidade == 1 ? '' : 's'}'
                    '${alterado ? ' • alterações não salvas' : ''}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final horario in _viewModel.horarios)
                  FilterChip(
                    label: Text(
                      '${horario.horaInicial} às ${horario.horaFinal}',
                    ),
                    selected: _viewModel.estaSelecionado(dia, horario.id),
                    selectedColor: const Color(0xFF1E1E1E),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _viewModel.estaSelecionado(dia, horario.id)
                          ? Colors.white
                          : Colors.black87,
                    ),
                    onSelected: salvando
                        ? null
                        : (_) => _viewModel.alternarHorario(dia, horario.id),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: salvando
                    ? null
                    : () => _viewModel.selecionarTodos(dia),
                child: const Text('Todos'),
              ),
              TextButton(
                onPressed: salvando ? null : () => _viewModel.limparDia(dia),
                child: const Text('Limpar'),
              ),
              const Spacer(),
              if (alterado)
                TextButton(
                  onPressed: salvando
                      ? null
                      : () => _viewModel.descartarAlteracoes(dia),
                  child: const Text('Descartar'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: (!alterado || salvando)
                    ? null
                    : () => _viewModel.salvarDia(dia),
                child: salvando
                    ? const SizedBox(
                        height: 16,
                        width: 16,
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
            ],
          ),
        ],
      ),
    );
  }
}