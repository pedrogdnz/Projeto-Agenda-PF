
import 'package:agendapf/presentation/views/login_view.dart';
import 'package:agendapf/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
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
                key: _viewModel.formKey,
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
                      requiredField: true,
                      isPassword: false,
                      controller: _viewModel.nomeController,
                      label: 'Nome',
                      validator: _viewModel.validateNome,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      isPassword: false,
                      controller: _viewModel.emailController,
                      label: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: _viewModel.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      isPassword: true,
                      controller: _viewModel.senhaController,
                      label: 'Senha',
                      validator: _viewModel.validateSenha,
                    ),

                    const SizedBox(height: 20),

                    CustomTextField(
                      requiredField: true,
                      isPassword: true,
                      controller: _viewModel.confirmarSenhaController,
                      label: 'Confirme sua senha',
                      validator: _viewModel.validateConfirmarSenha,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_viewModel.validate()) {
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
