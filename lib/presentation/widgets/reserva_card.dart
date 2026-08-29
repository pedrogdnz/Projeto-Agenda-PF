import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/presentation/viewmodels/reservas_viewmodel.dart';

/// Card de uma reserva na tela "Minhas Reservas": data em destaque, fundo,
/// descrição opcional e status. O botão de cancelar só aparece quando a
/// reserva ainda não passou.

class ReservaCard extends StatelessWidget {
  final ReservaComHorario item;
  final bool isPassada;
  final VoidCallback onCancelar;

  const ReservaCard({
    super.key,
    required this.item,
    required this.isPassada,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final data = item.reserva.dataReserva;

    final diaSemana = DateFormat('EEE', 'pt_BR').format(data).toUpperCase();
    final mes = DateFormat('MMM', 'pt_BR').format(data).toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPassada
                        ? Colors.grey.shade200
                        : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.day}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isPassada
                              ? Colors.grey.shade700
                              : Colors.white,
                        ),
                      ),
                      Text(
                        '$mes • $diaSemana',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPassada
                              ? Colors.grey.shade600
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.palette_outlined,
                        text:
                            "Fundo: ${item.reserva.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco'}",
                      ),
                      if (item.reserva.descricao.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          text: item.reserva.descricao,
                        ),
                      ],
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: isPassada
                            ? Icons.history
                            : Icons.check_circle_outline,
                        iconColor: isPassada ? Colors.grey : Colors.green,
                        text: isPassada ? "Concluída" : "Confirmada",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (!isPassada) ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancelar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar Reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _InfoRow({required this.icon, required this.text, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
