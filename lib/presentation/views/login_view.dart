import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/services/fake/fake_data_bloqueada.dart';
import 'package:agendapf/data/services/fake/fake_horario_service.dart';
import 'package:agendapf/data/services/fake/fake_reserva_service.dart';
import 'package:agendapf/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:agendapf/presentation/viewmodels/login_viewmodel.dart';
import 'package:agendapf/presentation/views/admin_home_view.dart';
import 'package:agendapf/presentation/views/calendar_view.dart';
import 'package:agendapf/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.addListener(_handleViewModelChange);
  }

  void _handleViewModelChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final sucesso = await _viewModel.enviar();
    if (!mounted) return;

    if (!sucesso) {
      final erro = _viewModel.erro;
      if (erro != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
      }
      return;
    }

    final resultado = _viewModel.resultado!;

    if (resultado.ehAdministrador) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
      );
      return;
    }

    // Uma única instância de AgendaRepository (e dos services que ela
    // encapsula) é criada aqui e reaproveitada por toda a sessão do aluno
    // — Calendário, Detalhes e Reservas devem enxergar as mesmas reservas
    // em memória, em vez de cada tela criar seu próprio fake isolado.
    final agendaRepository = AgendaRepository(
      dataBloqueadaService: FakeDataBloqueadaService(),
      horarioService: FakeHorarioService(),
      reservaService: FakeReservaService(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          alunoId: resultado.aluno!.id,
          viewModel: CalendarViewModel(agendaRepository: agendaRepository),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height / 100;
    final ehCadastro = _viewModel.ehCadastro;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image(image: AssetImage("images/ifpr_logo.png")),
            ),
          ),
          Container(
            height: size * 80,
            width: size * 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ehCadastro ? "Registro" : "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                  ),

                  Row(
                    children: [
                      Text(
                        ehCadastro ? "Já tem uma conta?" : "Não tem uma conta?",
                      ),
                      TextButton(
                        onPressed: _viewModel.carregando
                            ? null
                            : _viewModel.alternarModo,
                        child: Text(
                          ehCadastro ? 'Login' : 'Cadastre-se',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Form(
                    key: _viewModel.formKey,
                    child: Column(
                      children: [
                        if (ehCadastro) ...[
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
                            controller: _viewModel.matriculaController,
                            label: 'Matrícula',
                            keyboardType: TextInputType.number,
                            validator: _viewModel.validateMatricula,
                          ),
                          const SizedBox(height: 20),
                        ],

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
                          controller: _viewModel.senhaController,
                          label: 'Senha',
                          isPassword: true,
                          validator: _viewModel.validateSenha,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _viewModel.carregando ? null : _enviar,
                          child: _viewModel.carregando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  ehCadastro ? "Cadastrar" : "Login",
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
        ],
      ),
    );
  }
}
