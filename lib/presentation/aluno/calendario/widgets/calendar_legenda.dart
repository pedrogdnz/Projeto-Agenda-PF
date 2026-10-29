import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/motivo_bloqueio.dart';
import 'package:agendapf/presentation/utils/motivo_bloqueio_cor.dart';

class CalendarLegenda extends StatelessWidget {
  final Set<MotivoBloqueio> motivosPresentes;

  const CalendarLegenda({super.key, required this.motivosPresentes});

  @override
  Widget build(BuildContext context) {
    if (motivosPresentes.isEmpty) return const SizedBox.shrink();

    final motivosOrdenados = MotivoBloqueio.values
        .where(motivosPresentes.contains)
        .toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: motivosOrdenados
          .map((motivo) => _ItemLegenda(motivo: motivo))
          .toList(),
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  final MotivoBloqueio motivo;

  const _ItemLegenda({required this.motivo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: corParaMotivoBloqueio(motivo),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          descricaoMotivoBloqueio(motivo),
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ],
    );
  }
}
