import 'package:flutter/material.dart';

class AlunoPerfil extends StatefulWidget {
  const AlunoPerfil({super.key});

  @override
  State<AlunoPerfil> createState() => _AlunoPerfilState();
}

class _AlunoPerfilState extends State<AlunoPerfil> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Olá aluno"),
    );
  }
}