import 'package:agendapf/presentation/viewmodels/contador_viewmodel.dart';
import 'package:flutter/material.dart';

class ContadorPage extends StatefulWidget {
  const ContadorPage({super.key});

  @override
  State<ContadorPage> createState() => _ContadorPageState();
}

class _ContadorPageState extends State<ContadorPage> {
  late final ContadorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ContadorViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: _viewModel.contador,
          builder: (context, valorAtual, child) {
            return Text('Valor: $valorAtual');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.incrementar,
        child: Icon(Icons.add),
      ),
    );
  }
}
