import 'package:agendapf/data/repositories/administrador_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/data/services/fake/fake_administrador_service.dart';
import 'package:agendapf/data/services/fake/fake_aluno_service.dart';
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
      _mostrarErroSeHouver();
      return;
    }
    _navegarAposLogin();
  }

  Future<void> _entrarComGoogle() async {
    final sucesso = await _viewModel.entrarComGoogle();
    if (!mounted) return;
    if (!sucesso) {
      _mostrarErroSeHouver();
      return;
    }
    // Se ainda faltar a matrícula, a tela troca sozinha (via setState do
    // listener) para o formulário de completar cadastro — nada a navegar.
    if (_viewModel.resultado != null) {
      _navegarAposLogin();
    }
  }

  Future<void> _confirmarMatriculaGoogle() async {
    final sucesso = await _viewModel.confirmarMatriculaGoogle();
    if (!mounted) return;
    if (!sucesso) {
      _mostrarErroSeHouver();
      return;
    }
    _navegarAposLogin();
  }

  void _mostrarErroSeHouver() {
  final erro = _viewModel.erro;
  if (erro == null) return;

  final mostrarAcaoCadastro = !_viewModel.ehCadastro;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(erro),
      action: mostrarAcaoCadastro
          ? SnackBarAction(
              label: 'Cadastre-se',
              onPressed: _viewModel.alternarModo,
            )
          : null,
      duration: const Duration(seconds: 5),
    ),
  );
}

  void _navegarAposLogin() {
    final resultado = _viewModel.resultado!;

    final agendaRepository = AgendaRepository(
      dataBloqueadaService: FakeDataBloqueadaService(),
      horarioService: FakeHorarioService(),
      reservaService: FakeReservaService(),
    );

    final alunoRepository = AlunoRepository(
      alunoService: FakeAlunoService(),
      administradorService: FakeAdministradorService(),
    );

    final administradorRepository = AdministradorRepository(
      administradorService: FakeAdministradorService(),
      alunoService: FakeAlunoService(),
    );

    if (resultado.ehAdministrador) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomePage(
            agendaRepository: agendaRepository,
            alunoRepository: alunoRepository,
            administradorRepository: administradorRepository,
          ),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          alunoId: resultado.aluno!.id,
          viewModel: CalendarViewModel(agendaRepository: agendaRepository),
          authRepository: _viewModel.authRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(35.0),
              child: _viewModel.aguardandoMatriculaGoogle
                  ? _buildFormMatriculaGoogle()
                  : _buildFormPrincipal(),
            ),
          ),
        ],
      ),
    );
  }

  /// Formulário de Login/Cadastro por e-mail e senha, mais o botão de
  /// entrar com Google (fluxo do aluno).
  Widget _buildFormPrincipal() {
    final ehCadastro = _viewModel.ehCadastro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ehCadastro ? "Registro" : "Login",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        ),

        Row(
          children: [
            Text(ehCadastro ? "Já tem uma conta?" : "Não tem uma conta?"),
            TextButton(
              onPressed: _viewModel.carregando ? null : _viewModel.alternarModo,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        ehCadastro ? "Cadastrar" : "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),

        SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),

        SizedBox(height: 16),

        Text(
          'Aluno? Entre com sua conta institucional:',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),

        SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _viewModel.carregando ? null : _entrarComGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Entrar com Google (@estudantes.ifpr.edu.br)'),
          ),
        ),
      ],
    );
  }

  /// Aparece só no primeiro login via Google, quando falta a matrícula
  /// pra concluir o cadastro do aluno.
  Widget _buildFormMatriculaGoogle() {
    final pendente = _viewModel.contaGooglePendente!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quase lá!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        SizedBox(height: 8),
        Text(
          'Olá, ${pendente.nome}. Falta só sua matrícula pra concluir o cadastro.',
        ),
        SizedBox(height: 24),

        Form(
          key: _viewModel.matriculaGoogleFormKey,
          child: CustomTextField(
            requiredField: true,
            isPassword: false,
            controller: _viewModel.matriculaController,
            label: 'Matrícula',
            keyboardType: TextInputType.number,
            validator: _viewModel.validateMatricula,
          ),
        ),

        SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _viewModel.carregando
                    ? null
                    : _viewModel.cancelarCadastroGoogle,
                child: Text('Cancelar'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed:
                    _viewModel.carregando ? null : _confirmarMatriculaGoogle,
                child: _viewModel.carregando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Concluir cadastro',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}