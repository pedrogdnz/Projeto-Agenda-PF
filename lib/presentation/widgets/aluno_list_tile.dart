import 'package:flutter/material.dart';
import 'package:agendapf/data/models/aluno_model.dart';

/// Item da lista de Alunos no painel do Administrador: nome em destaque
/// e matrícula como subtítulo. Ao tocar, abre os detalhes do aluno.
class AlunoListTile extends StatelessWidget {
  final Aluno aluno;
  final VoidCallback onTap;

  const AlunoListTile({super.key, required this.aluno, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                child: Text(
                  aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Matrícula: ${aluno.matricula}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
