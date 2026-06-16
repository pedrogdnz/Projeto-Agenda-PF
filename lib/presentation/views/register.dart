import 'package:agendapf/presentation/views/login.dart';
import 'package:agendapf/presentation/views/textField.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height / 100;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset("images/ifpr_logo.png"),
            ),
          ),

          Container(
            height: size * 80,
            width: size * 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(80)),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Registre-se",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),

                    Row(
                      children: [
                        const Text('Já tem uma conta?'),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: nomeController,
                      label: "Nome",
                      isPassword: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Informe seu nome";
                        }
                        return null;
                      },
                      requiredField: true,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: emailController,
                      label: "E-mail",
                      keyboardType: TextInputType.emailAddress,
                      isPassword: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Informe seu e-mail";
                        }

                        if (!value.contains('@')) {
                          return "E-mail inválido";
                        }

                        return null;
                      },
                      requiredField: true,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: senhaController,
                      label: "Senha",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Informe sua senha";
                        }

                        if (value.length < 6) {
                          return "A senha deve ter pelo menos 6 caracteres";
                        }

                        return null;
                      },
                      requiredField: true,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      controller: confirmarSenhaController,
                      label: "Confirme sua senha",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Confirme sua senha";
                        }

                        if (value != senhaController.text) {
                          return "As senhas não coincidem";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Cadastrar",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
