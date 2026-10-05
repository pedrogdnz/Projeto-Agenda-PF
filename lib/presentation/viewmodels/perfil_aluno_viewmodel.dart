import 'package:flutter/material.dart';
import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/repositories/auth_repository.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';
import 'package:agendapf/data/services/firebase/firebase_aluno_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class MatriculaJaEmUsoException implements Exception {
  final String mensagem;

  const MatriculaJaEmUsoException([
    this.mensagem = 'Esta matrícula já está em uso por outro aluno.',
  ]);
  @override
  String toString() => mensagem;
}

class PerfilAlunoViewModel extends ChangeNotifier {
  final String alunoId;
  final AlunoService _alunoService;
  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();
  final cursoController = TextEditingController();
  final turmaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _fotoBytes;
  bool _salvandoFoto = false;

  Uint8List? get fotoBytes => _fotoBytes;
  bool get temFoto => _fotoBytes != null;
  bool get salvandoFoto => _salvandoFoto;

  void _atualizarCacheFoto() {
    final b64 = _aluno?.fotoBase64;
    _fotoBytes = (b64 == null || b64.isEmpty) ? null : base64Decode(b64);
  }

  PerfilAlunoViewModel({
    required this.alunoId,
    required AuthRepository authRepository,
    AlunoService? alunoService,
  }) : _authRepository = authRepository,
       _alunoService = alunoService ?? FirebaseAlunoService();

  Aluno? _aluno;
  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  Aluno? get aluno => _aluno;
  String? get email => _aluno?.email;
  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;

  @override
  void dispose() {
    nomeController.dispose();
    matriculaController.dispose();
    cursoController.dispose();
    turmaController.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final aluno = await _alunoService.buscarPorId(alunoId);
      _aluno = aluno;
      _atualizarCacheFoto();
      if (aluno != null) {
        nomeController.text = aluno.nome;
        matriculaController.text = aluno.matricula;
        cursoController.text = aluno.tipoCurso?.titulo??"";
        cursoController.text = aluno.turma?.titulo??"";
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu nome';
    return null;
  }

  String? validateMatricula(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe sua matrícula';
    return null;
  }

  Future<bool> salvar() async {
    final valido = formKey.currentState?.validate() ?? false;
    if (!valido) return false;

    final atual = _aluno;
    if (atual == null) return false;

    _salvando = true;
    _erro = null;
    notifyListeners();

    try {
      final novaMatricula = matriculaController.text.trim();

      if (novaMatricula != atual.matricula) {
        final existente = await _alunoService.buscarPorEmailOuMatricula(
          novaMatricula,
        );
        if (existente != null && existente.id != atual.id) {
          throw const MatriculaJaEmUsoException();
        }
      }

      final atualizado = atual.copyWith(
        nome: nomeController.text.trim(),
        matricula: novaMatricula,
      );

      _aluno = await _alunoService.atualizar(atualizado);
      return true;
    } catch (e) {
      _erro = e.toString();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _authRepository.logout();

  /// Escolhe (câmera/galeria) e salva a foto. Retorna false se o usuário
/// cancelou ou se deu erro (nesse caso [erro] fica preenchido).
Future<bool> alterarFoto(ImageSource origem) async {
  final atual = _aluno;
  if (atual == null) return false;

  try {
    final arquivo = await _picker.pickImage(
      source: origem,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (arquivo == null) return false; // cancelou

    _salvandoFoto = true;
    _erro = null;
    notifyListeners();

    final bytes = await arquivo.readAsBytes();
    _aluno = await _alunoService.atualizar(
      atual.copyWith(fotoBase64: base64Encode(bytes)),
    );
    _atualizarCacheFoto();
    return true;
  } catch (e) {
    _erro = e.toString();
    return false;
  } finally {
    _salvandoFoto = false;
    notifyListeners();
  }
}

Future<bool> removerFoto() async {
  final atual = _aluno;
  if (atual == null) return false;

  _salvandoFoto = true;
  _erro = null;
  notifyListeners();

  try {
    _aluno = await _alunoService.atualizar(atual.copyWith(removerFoto: true));
    _atualizarCacheFoto();
    return true;
  } catch (e) {
    _erro = e.toString();
    return false;
  } finally {
    _salvandoFoto = false;
    notifyListeners();
  }
}
}
