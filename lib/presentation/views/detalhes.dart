import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/presentation/views/reservas.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key, required this.data});

  final DateTime data;

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  TimeOfDay? horarioSelecionado;

  Future<void> selecionarHorario() async {
    final TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        horarioSelecionado = horario;
      });
    }
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_rounded),
              ],
            ),

            const Text("Confirme sua reserva"),

            Text(
              '${widget.data.day}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              DateFormat('EEEE', 'pt_BR').format(widget.data),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Horário:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: selecionarHorario,
              borderRadius: BorderRadius.circular(15),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: const Icon(Icons.access_time),
                ),
                child: Text(
                  horarioSelecionado == null
                      ? 'Selecione um horário'
                      : horarioSelecionado!.format(context),
                ),
              ),
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
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Preto",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {},
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
                Text(
                  "*Opcional",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),

            TextFormField(
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
                onPressed: () {
                  if (horarioSelecionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione um horário'),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Reservas(),
                    ),
                  );
                },
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