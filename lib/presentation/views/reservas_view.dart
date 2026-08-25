import 'package:flutter/material.dart';

class Reservas extends StatelessWidget {
  const Reservas({super.key});

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

              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: ReservaCard(),
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
                  IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, 
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white)), 
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

class ReservaCard extends StatefulWidget {
  const ReservaCard({super.key});

  @override
  State<ReservaCard> createState() => _ReservaCardState();
}

class _ReservaCardState extends State<ReservaCard> {
  @override
  Widget build(BuildContext context) {
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
                      '10',
                       style: TextStyle(
                       fontSize: 35,
                       fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Segunda",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            Text(
              "Cor de Fundo:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Horário:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Status:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
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
