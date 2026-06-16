import 'package:flutter/material.dart';

class Detalhes extends StatelessWidget {
  const Detalhes({super.key, required this.data,});
    final DateTime data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data')),
      body: Center(
        child: Text(
          '${data.day}/${data.month}/${data.year}',
        ),
      ),
    );
  }
}