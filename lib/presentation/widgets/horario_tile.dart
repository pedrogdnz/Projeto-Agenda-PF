import 'package:flutter/material.dart';
import 'package:agendapf/data/models/enum/cor_fundo_horario.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';

/// Um horário pré-cadastrado (RN04) que o aluno pode selecionar na tela de
/// Detalhes. A disponibilidade é calculada em função do fundo atualmente
/// escolhido.

class HorarioTile extends StatelessWidget {
  final HorarioDoDia item;
  final CorFundoHorario fundoSelecionado;
  final bool selecionado;
  final VoidCallback onTap;

  const HorarioTile({
    super.key,
    required this.item,
    required this.fundoSelecionado,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final horario = item.horario;
    final disponivel = item.disponivelPara(fundoSelecionado);

    return Opacity(
      opacity: disponivel ? 1 : 0.5,
      child: InkWell(
        onTap: disponivel ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selecionado ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selecionado ? Colors.black : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: selecionado ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${horario.horaInicial} às ${horario.horaFinal}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selecionado ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (!disponivel)
                Text(
                  'Ocupado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selecionado ? Colors.white70 : Colors.red.shade300,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
