import 'package:flutter/material.dart';

/// Menu central do administrador (RF09/RF10/RF11 - navegação).
///
/// Apresenta atalhos para a configuração do ano letivo e para os 4 CRUDs
/// administrativos do sistema. Esta tela não possui lógica de negócio nem
/// estado próprio, apenas navegação, por isso não utiliza ViewModel
/// (mesmo padrão adotado em `Reservas`, que também é puramente de exibição).
///
/// As telas de destino de cada CRUD ainda serão implementadas; até lá, os
/// atalhos ainda não conectados mostram um aviso ao serem tocados.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Painel do Administrador",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Selecione um módulo para gerenciar",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),

              _AdminMenuButton(
                icon: Icons.event_available,
                label: 'Configuração do Ano Letivo',
                onTap: () => _abrirModulo(context, 'Configuração do Ano Letivo'),
              ),
              const SizedBox(height: 16),

              _AdminMenuButton(
                icon: Icons.people_alt_outlined,
                label: 'Alunos',
                onTap: () => _abrirModulo(context, 'CRUD de Alunos'),
              ),
              const SizedBox(height: 16),

              _AdminMenuButton(
                icon: Icons.calendar_month_outlined,
                label: 'Datas e Horários',
                onTap: () => _abrirModulo(context, 'CRUD de Datas e Horários'),
              ),
              const SizedBox(height: 16),

              _AdminMenuButton(
                icon: Icons.event_note_outlined,
                label: 'Reservas',
                onTap: () => _abrirModulo(context, 'CRUD de Reservas'),
              ),
              const SizedBox(height: 16),

              _AdminMenuButton(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Administradores',
                onTap: () => _abrirModulo(context, 'CRUD de Administradores'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: substituir por Navigator.push para cada tela real assim que
  // as views dos CRUDs forem implementadas.
  void _abrirModulo(BuildContext context, String nome) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nome: tela ainda não implementada')),
    );
  }
}

class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
