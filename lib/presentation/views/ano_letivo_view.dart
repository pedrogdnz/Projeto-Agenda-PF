import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/tipo_configuracao_ano_letivo.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/presentation/viewmodels/ano_letivo_viewmodel.dart';
import 'package:agendapf/presentation/widgets/admin_menu_button.dart';
import 'package:agendapf/presentation/widgets/ano_letivo_calendar.dart';

class ConfiguracaoAnoLetivoPage extends StatefulWidget {
  final AgendaRepository agendaRepository;

  const ConfiguracaoAnoLetivoPage({super.key, required this.agendaRepository});

  @override
  State<ConfiguracaoAnoLetivoPage> createState() =>
      _ConfiguracaoAnoLetivoPageState();
}

class _ConfiguracaoAnoLetivoPageState extends State<ConfiguracaoAnoLetivoPage> {
  late final AnoLetivoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnoLetivoViewModel(agendaRepository: widget.agendaRepository);
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarDiasBloqueados();
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

    final mensagemInfo = _viewModel.mensagemInfo;
    if (mensagemInfo != null) {
      _viewModel.limparMensagemInfo();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagemInfo)));
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
    final sucesso = await _viewModel.confirmar();
    if (!mounted || !sucesso) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração salva com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modoAtivo = _viewModel.modoAtivo;

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
          'Configuração do Ano Letivo',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              if (modoAtivo != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: modoAtivo == TipoConfiguracaoAnoLetivo.ferias
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: modoAtivo == TipoConfiguracaoAnoLetivo.ferias
                          ? Colors.red.shade200
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          modoAtivo.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: _viewModel.cancelarModo,
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: _viewModel.confirmando ? null : _confirmar,
                        child: _viewModel.confirmando
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              _viewModel.carregandoDiasBloqueados
                  ? const Center(child: LinearProgressIndicator())
                  : AnoLetivoCalendar(
                      focusedDay: _viewModel.focusedDay,
                      modoAtivo: modoAtivo,
                      datasSelecionadas: _viewModel.datasSelecionadas,
                      diasBloqueados: _viewModel.diasBloqueados,
                      diaSelecionavel: _viewModel.diaSelecionavel,
                      onDataArrastada: _viewModel.adicionarDataArrastada,
                      onDataTocada: _viewModel.alternarDataTocada,
                      onPageChanged: _viewModel.changePage,
                    ),

              const SizedBox(height: 20),

              AdminMenuButton(
                icon: Icons.beach_access_outlined,
                label: 'Configurar férias',
                ativo: modoAtivo == TipoConfiguracaoAnoLetivo.ferias,
                onTap: _viewModel.ativarModoFerias,
              ),
              const SizedBox(height: 12),
              AdminMenuButton(
                icon: Icons.event_outlined,
                label: 'Configurar feriados',
                ativo: modoAtivo == TipoConfiguracaoAnoLetivo.feriados,
                onTap: _viewModel.ativarModoFeriados,
              ),
              const SizedBox(height: 12),
              AdminMenuButton(
                icon: Icons.schedule_outlined,
                label: 'Configurar horários gerais',
                onTap: _viewModel.tentarAbrirHorariosGerais,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
