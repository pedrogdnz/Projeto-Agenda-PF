import 'package:agendapf/presentation/viewmodels/admin_reservas_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';

/// Card de reserva no painel do administrador: aluno, data e horário.
/// Reservas antigas só podem ser removidas (editar não faz sentido).
class AdminReservaCard extends StatelessWidget {
  final ReservaDoAluno item;
  final bool isPassada;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const AdminReservaCard({
    super.key,
    required this.item,
    required this.isPassada,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final reserva = item.reserva;
    final data = reserva.dataReserva;
    final horario = item.horario;

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
                      Text(
                        item.aluno?.nome ?? 'Aluno não encontrado',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (item.aluno != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Matrícula: ${item.aluno!.matricula}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.access_time,
                        text: horario != null
                            ? '${horario.horaInicial} às ${horario.horaFinal}'
                            : 'Horário não encontrado',
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.palette_outlined,
                        text:
                            'Fundo: ${reserva.corFundo == CorFundoHorario.preto ? 'Preto' : 'Branco'}',
                      ),
                      if (reserva.descricao.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _InfoRow(
                          icon: Icons.notes_outlined,
                          text: reserva.descricao,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExcluir,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remover'),
                  ),
                ),
                if (!isPassada) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEditar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Editar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
