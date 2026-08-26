import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
                onTap: () =>
                    _abrirModulo(context, 'Configuração do Ano Letivo'),
              ),
              const SizedBox(height: 16),

              _AdminMenuButton(
                icon: Icons.people_alt_outlined,
                label: 'Alunos',
                onTap: () => _abrirModulo(context, 'CRUD de Alunos'),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pendências: tela ainda não implementada'),
              ),
            );
          }

          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conta: tela ainda não implementada'),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Painel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions_outlined),
            activeIcon: Icon(Icons.pending_actions),
            label: 'Pendências',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Conta',
          ),
        ],
      ),
    );
  }

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
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
