import 'package:agendapf/presentation/aluno/minhas_reservas/reservas_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';

/// Card de uma reserva otimizado e proporcional.
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
    final horario = item.horario;

    final diaSemana = DateFormat('EEE', 'pt_BR').format(data).toUpperCase();
    final mes = DateFormat('MMM', 'pt_BR').format(data).toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // CABEÇALHO: Data + Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPassada ? Colors.grey.shade300 : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${data.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPassada ? Colors.grey.shade700 : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$diaSemana, $mes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                _StatusChip(isPassada: isPassada),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),

            // CONTEÚDO PRINCIPAL: Horário + Cor de Fundo em Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (horario != null)
                  _InfoTag(
                    icon: Icons.access_time_rounded,
                    label: '${horario.horaInicial} às ${horario.horaFinal}',
                    backgroundColor: const Color(0xFFF4F6F9),
                    textColor: const Color(0xFF2C3E50),
                  )
                else
                  const _InfoTag(
                    icon: Icons.error_outline,
                    label: 'Horário indisponível',
                    backgroundColor: Color(0xFFFFF3CD),
                    textColor: Color(0xFF856404),
                  ),
                _InfoTag(
                  icon: Icons.palette_outlined,
                  label: 'Fundo: ${item.reserva.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco'}',
                  backgroundColor: const Color(0xFFF4F6F9),
                  textColor: const Color(0xFF2C3E50),
                ),
              ],
            ),

            // DESCRIÇÃO (Se houver)
            if (item.reserva.descricao.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.reserva.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // BOTÃO DE CANCELAR
            if (!isPassada) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancelar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text(
                    'Cancelar Reserva',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip de status elegante (Confirmada / Concluída)
class _StatusChip extends StatelessWidget {
  final bool isPassada;

  const _StatusChip({required this.isPassada});

  @override
  Widget build(BuildContext context) {
    final bgColor = isPassada ? Colors.grey.shade100 : const Color(0xFFE8F5E9);
    final textColor = isPassada ? Colors.grey.shade600 : const Color(0xFF2E7D32);
    final icon = isPassada ? Icons.history : Icons.check_circle_rounded;
    final text = isPassada ? 'Concluída' : 'Confirmada';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag reutilizável para exibir metadados da reserva de forma compacta
class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}