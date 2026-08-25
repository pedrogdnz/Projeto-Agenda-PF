import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

class FakeAlunoService implements AlunoService {
  final List<Aluno> _alunos = [
    Aluno(
      id: '1',
      nome: 'Ana Clara Silva',
      matricula: '20240001',
      email: 'ana.clara@escola.com',
      senha: '123456',
      criadoEm: DateTime(2026, 8, 20),
    ),
    Aluno(
      id: '2',
      nome: 'Beatriz Souza',
      matricula: '20240002',
      email: 'beatriz@escola.com',
      senha: '123456',
      criadoEm: DateTime(2026, 8, 21),
    ),
    Aluno(
      id: '3',
      nome: 'Carolina Oliveira',
      matricula: '20240003',
      email: 'carolina@escola.com',
      senha: '123456',
      criadoEm: DateTime(2026, 8, 22),
    ),
  ];

  @override
  Future<List<Aluno>> buscarTodos() async {
    return List.unmodifiable(_alunos);
  }
}
