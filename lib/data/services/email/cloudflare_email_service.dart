
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CloudflareEmailService {
  static const String _workerUrl =
      'https://email-worker.agendapf-backend.workers.dev/send-notification';

  final FirebaseAuth _auth;
  final http.Client _client;

  CloudflareEmailService({
    FirebaseAuth? auth,
    http.Client? client,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _client = client ?? http.Client();

  Future<void> enviarNotificacao({
    required String tipo,
    required String alunoId,
    required String alunoNome,
    required String alunoEmail,
    required String data,
    required String horario,
    required String fundo,
    required String professor,
    required String descricao,
    required String origem,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Nenhum usuário está autenticado.');
    }

    final idToken = await usuario.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Não foi possível obter o token Firebase.');
    }

    final response = await _client.post(
      Uri.parse(_workerUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'tipo': tipo,
        'alunoId': alunoId,
        'alunoNome': alunoNome,
        'alunoEmail': alunoEmail,
        'data': data,
        'horario': horario,
        'fundo': fundo,
        'professor': professor,
        'descricao': descricao,
        'origem': origem,
      }),
    );

    final Map<String, dynamic> resultado;

    try {
      resultado = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Resposta inválida do servidor.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ${response.statusCode}: ${resultado['error']}',
      );
    }

    if (resultado['success'] != true) {
      throw Exception(
        'Falha no envio. Aluno: ${resultado['aluno']}; '
        'Administrador: ${resultado['admin']}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
