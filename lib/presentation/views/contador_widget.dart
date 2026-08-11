import 'package:flutter/material.dart';

class ContadorWidget extends StatefulWidget {
  final int valorInicial;

  const ContadorWidget({super.key, required this.valorInicial});

  @override
  State<ContadorWidget> createState() => _ContadorWidgetState();
}

class _ContadorWidgetState extends State<ContadorWidget> {
  late int _contador;
  late final int _valorOriginal; // Guardará o primeiro valor recebido

  @override
  void initState() {
    super.initState();
    _contador = widget.valorInicial;
    _valorOriginal =
        widget.valorInicial; // Salva o valor original apenas na criação
  }

  @override
  void didUpdateWidget(ContadorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se o pai enviou um novo valor, atualiza o contador atual,
    // mas o _valorOriginal continua o mesmo!
    if (oldWidget.valorInicial != widget.valorInicial) {
      setState(() {
        _contador = widget.valorInicial;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Valor Atual: $_contador'),
        Text('Valor Original: $_valorOriginal'), // Exibe o valor inicial fixo
        Text(
          'Valor Anterior: ${widget.valorInicial}',
        ), // Opcional: para ver o valor que veio do pai
      ],
    );
  }
}
