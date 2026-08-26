import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/horario_model.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart';

class Reservas extends StatefulWidget {
  const Reservas({super.key});

  @override
  State<Reservas> createState() => _ReservasState();
}

class _ReservasState extends State<Reservas> {
  late final ReservasViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReservasViewModel();
    _viewModel.addListener(_handleViewModelChange);
    _viewModel.carregarReservas();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          Container(height: double.infinity, color: const Color(0xFF1E1E1E)),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: _viewModel.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _viewModel.reservas.isEmpty
                  ? const Center(child: Text('Nenhuma reserva encontrada'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _viewModel.reservas.length,
                      itemBuilder: (context, index) {
                        final item = _viewModel.reservas[index];
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: ReservaCard(
                            item: item,
                            onCancelar: () =>
                                _viewModel.cancelarReserva(item.reserva.id),
                          ),
                        );
                      },
                    ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Image.asset('images/user.png'),
                  const SizedBox(width: 12),
                  const Text(
                    'Reservas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservaCard extends StatelessWidget {
  final ReservaComHorario item;
  final VoidCallback onCancelar;

  const ReservaCard({super.key, required this.item, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    final data = item.reserva.dataReserva;
    final horario = item.horario;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Container(
                  height: 40.0,
                  width: 3.0,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                ),
                Column(
                  children: [
                    Text(
                      '${data.day}',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE', 'pt_BR').format(data),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            Text(
              "Cor de Fundo: ${horario == null ? '-' : (horario.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco')}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Horário: ${horario == null ? '-' : '${horario.horaInicial} às ${horario.horaFinal}'}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Status: Confirmada",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onCancelar,
              child: Text(
                "Cancelar Reserva",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
