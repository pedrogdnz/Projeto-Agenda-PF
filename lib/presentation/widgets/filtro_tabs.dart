import 'package:flutter/material.dart';

/// Alternância em formato de abas (ChoiceChip) entre duas ou mais opções,
/// destacando a selecionada em preto. funciona com qualquer tipo T.
class FiltroTabs<T> extends StatelessWidget {
  final T filtroAtual;
  final Map<T, String> opcoes;
  final ValueChanged<T> onFiltroChanged;

  const FiltroTabs({
    super.key,
    required this.filtroAtual,
    required this.opcoes,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context) {
    final chaves = opcoes.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final chave in chaves) ...[
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text(opcoes[chave]!)),
                selected: filtroAtual == chave,
                selectedColor: const Color(0xFF1E1E1E),
                labelStyle: TextStyle(
                  color: filtroAtual == chave ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => onFiltroChanged(chave),
              ),
            ),
            if (chave != chaves.last) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}
