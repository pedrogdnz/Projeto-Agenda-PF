import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/repositories/administrador_repository.dart';
import 'package:agendapf/data/repositories/aluno_repository.dart';
import 'package:agendapf/data/services/fake/fake_administrador_service.dart';
import 'package:agendapf/data/services/fake/fake_aluno_service.dart';
import 'package:agendapf/data/repositories/agenda_repository.dart';
import 'package:agendapf/data/services/fake/fake_data_bloqueada.dart';
import 'package:agendapf/data/services/fake/fake_disponibilidade_padrao_service.dart';
import 'package:agendapf/data/services/fake/fake_horario_service.dart';
import 'package:agendapf/data/services/fake/fake_reserva_service.dart';
import 'package:agendapf/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:agendapf/presentation/viewmodels/login_viewmodel.dart';
import 'package:agendapf/presentation/views/admin_home_view.dart';
import 'package:agendapf/presentation/views/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:agendapf/presentation/utils/password_validatior.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel;

  // Apenas estado visual (mostrar/ocultar senha).
  bool _ocultarSenha = true;

  // Cores / medidas do layout do Figma.
  static const Color _corFundo = Color(0xFFF0F0F0);
  static const double _alturaHeader = 180;
  static const double _raioCurva = 80;

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

    // 1. Instância compartilhada do FakeHorarioService
    final horarioService = FakeHorarioService();

    // 2. Instâncias dos Repositórios usando a mesma instância de horarioService
    final agendaRepository = AgendaRepository(
      dataBloqueadaService: FakeDataBloqueadaService(),
      horarioService: horarioService,
      reservaService: FakeReservaService(),
    );

    final disponibilidadePadraoRepository = DisponibilidadePadraoRepository(
      disponibilidadeService: FakeDisponibilidadePadraoService(),
      horarioService: horarioService,
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
            DisponibilidadePadraoRepository:
                disponibilidadePadraoRepository, // Passado aqui
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

  //////////////////////////////////////
  // LAYOUT
  //////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final aguardandoGoogle = _viewModel.aguardandoMatriculaGoogle;

    return Scaffold(
      backgroundColor: _corFundo,
      body: Stack(
        children: [
          // Fundo gradiente do header (preto -> cinza escuro)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _alturaHeader + _raioCurva,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF000000), Color(0xFF5C5C5C)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          aguardandoGoogle
                              ? _buildHeader(
                                  titulo: 'Quase lá!',
                                  subtitulo: const SizedBox.shrink(),
                                )
                              : _buildHeaderPrincipal(),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: _corFundo,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(_raioCurva),
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                21,
                                50,
                                21,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (aguardandoGoogle)
                                    _buildFormMatriculaGoogle()
                                  else
                                    _buildFormPrincipal(),
                                  const Spacer(),
                                  const SizedBox(height: 24),
                                  _buildLogoIF(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Câmera (com alça saindo do topo)
          Positioned(
            top: 0,
            right: 25,
            child: Image.asset('images/camera.png', width: 150),
          ),
        ],
      ),
    );
  }

  /// Header base: título branco grande + subtítulo.
  Widget _buildHeader({required String titulo, required Widget subtitulo}) {
    return SizedBox(
      height: _alturaHeader,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            subtitulo,
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPrincipal() {
    final ehCadastro = _viewModel.ehCadastro;

    return _buildHeader(
      titulo: ehCadastro ? 'Registro' : 'Login',
      subtitulo: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Row(
          children: [
            Text(
              ehCadastro ? 'Já tem uma conta? ' : 'Não tem uma conta? ',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            GestureDetector(
              onTap: _viewModel.carregando ? null : _viewModel.alternarModo,
              child: Text(
                ehCadastro ? 'Login' : 'Cadastre-se',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo com label em cima, fundo branco, cantos arredondados e sombra.
  Widget _buildCampo({
    required String label,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    bool isSenha = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isSenha && _ocultarSenha,
            validator: validator,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: isSenha
                  ? IconButton(
                      icon: Icon(
                        _ocultarSenha
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black87,
                      ),
                      onPressed: () =>
                          setState(() => _ocultarSenha = !_ocultarSenha),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Botão estilo "trilho": pílula preta à esquerda sobre trilho cinza.
  Widget _buildBotaoTrilho({
    required String texto,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 36,
            width: double.infinity,
            color: const Color(0xFFD9D9D9),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.59,
                heightFactor: 1,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicadorCarregando() {
    return SizedBox(
      height: 40,
      child: Center(
        child: _viewModel.carregando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.red,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildLogoIF() {
    return Center(
      child: Image.asset(
        'images/logo_ifpr_black.png',
        height: 70,
        errorBuilder: (_, __, ___) => const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'INSTITUTO\nFEDERAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                height: 1.1,
              ),
            ),
            Text('Paraná', style: TextStyle(fontSize: 9)),
          ],
        ),
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
        Form(
          key: _viewModel.formKey,
          child: Column(
            children: [
              if (ehCadastro) ...[
                _buildCampo(
                  label: 'Nome:',
                  controller: _viewModel.nomeController,
                  validator: _viewModel.validateNome,
                ),
                const SizedBox(height: 20),
                _buildCampo(
                  label: 'Matrícula:',
                  controller: _viewModel.matriculaController,
                  keyboardType: TextInputType.number,
                  validator: _viewModel.validateMatricula,
                ),
                const SizedBox(height: 20),
              ],

              _buildCampo(
                label: 'E-mail:',
                controller: _viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _viewModel.validateEmail,
                hint: 'aluno@exemplo.com',
              ),

              const SizedBox(height: 20),

              _buildCampo(
                label: 'Senha:',
                controller: _viewModel.senhaController,
                isSenha: true,
                validator: PasswordValidator.validate,
              ),
            ],
          ),
        ),

        if (!ehCadastro)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              // Sem função definida no arquivo original.
              onPressed: _viewModel.carregando ? null : () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(fontSize: 12),
              ),
            ),
          )
        else
          const SizedBox(height: 12),

        const SizedBox(height: 28),

        _buildBotaoTrilho(
          texto: ehCadastro ? 'Cadastrar' : 'Login',
          onPressed: _viewModel.carregando ? null : _enviar,
        ),

        _buildIndicadorCarregando(),

        const SizedBox(height: 4),

        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            'Aluno? Entre com sua conta institucional:',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _viewModel.carregando ? null : _entrarComGoogle,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1.2),
                shape: const StadiumBorder(),
              ),
              icon: Image.asset('images/google_logo.png', width: 22, height: 22),
              label: const Text(
                'Entrar com Google (@estudantes.ifpr.edu.br)',
                style: TextStyle(fontSize: 12),
              ),
            ),
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
          'Olá, ${pendente.nome}. Falta só sua matrícula pra concluir o cadastro.',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 24),

        Form(
          key: _viewModel.matriculaGoogleFormKey,
          child: _buildCampo(
            label: 'Matrícula:',
            controller: _viewModel.matriculaController,
            keyboardType: TextInputType.number,
            validator: _viewModel.validateMatricula,
          ),
        ),

        const SizedBox(height: 28),

        _buildBotaoTrilho(
          texto: 'Concluir cadastro',
          onPressed: _viewModel.carregando ? null : _confirmarMatriculaGoogle,
        ),

        _buildIndicadorCarregando(),

        Center(
          child: TextButton(
            onPressed: _viewModel.carregando
                ? null
                : _viewModel.cancelarCadastroGoogle,
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}
