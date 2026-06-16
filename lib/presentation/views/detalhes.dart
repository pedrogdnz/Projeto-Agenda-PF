import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Detalhes extends StatelessWidget {
  const Detalhes({super.key, required this.data});
  final DateTime data;

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
                Text(
                  "Sua Seleção",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Expanded(child: Container()),
                Icon(Icons.calendar_today_rounded),
              ],
            ),
            Text("Confirme sua reserva"),
            Text(
              '${data.day}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE', 'pt_BR').format(data),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: 20),

            Text("Horário:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Cor do fundo:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {},
                  child: Text("Preto", style: TextStyle(color: Colors.white)),
                ),
                TextButton(onPressed: () {}, child: Text("Branco")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Descrição ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("*Opcional", style: TextStyle(fontSize: 12)),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {},
                child: Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
