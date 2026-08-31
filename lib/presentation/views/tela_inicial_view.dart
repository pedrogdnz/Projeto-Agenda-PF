import 'package:flutter/material.dart';

class TelaInicialView extends StatefulWidget {
  const TelaInicialView({super.key});

  @override
  State<TelaInicialView> createState() => _TelaInicialViewState();
}

class _TelaInicialViewState extends State<TelaInicialView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          // 1. PAINEL INFERIOR (BRANCO)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.42,
            child: Container(
              color: const Color(0xFFF7F7F9),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Reserve o laboratório\nsem sair de casa.',
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xE6000000),
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Começar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CARD SUPERIOR 
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.62,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  
                ),
                child: Stack(
                  children: [
                    // Imagem de fundo
                    Positioned.fill(
                      child: Image.asset(
                        'images/fotoinicial.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradiente escuro sobre a imagem
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.4),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Conteúdo do topo
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lab PF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Comece,\nÉ sua hora de criar.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: Image.asset(
                                    'images/ifpr_logo.png',
                                    height: 48,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}