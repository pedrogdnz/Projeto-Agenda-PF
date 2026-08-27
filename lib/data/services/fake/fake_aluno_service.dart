import 'package:agendapf/data/models/aluno_model.dart';
import 'package:agendapf/data/services/abstract/aluno_data_source.dart';

class FakeAlunoService implements AlunoService {
  final List<Aluno> _alunos = [
    Aluno(
      id: '1',
      nome: 'Ana Clara Silva',
      matricula: '20240001',
      email: 'a@escola.com',
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

  @override
  Future<Aluno?> buscarPorId(String id) async {
    for (final aluno in _alunos) {
      if (aluno.id == id) return aluno;
    }
    return null;
  }

  @override
  Future<Aluno?> buscarPorEmailOuMatricula(String identificador) async {
    final query = identificador.trim().toLowerCase();

    for (final aluno in _alunos) {
      if (aluno.email.toLowerCase() == query ||
          aluno.matricula.toLowerCase() == query) {
        return aluno;
      }
    }
    return null;
  }

  @override
  Future<List<Aluno>> buscarPorNomeOuMatricula(String query) async {
    final termo = query.trim().toLowerCase();
    if (termo.isEmpty) return List.unmodifiable(_alunos);

    return _alunos
        .where(
          (aluno) =>
              aluno.nome.toLowerCase().contains(termo) ||
              aluno.matricula.toLowerCase().contains(termo),
        )
        .toList(growable: false);
  }

  @override
  Future<Aluno> criar(Aluno aluno) async {
    final novoAluno = aluno.copyWith(id: _gerarProximoId());
    _alunos.add(novoAluno);
    return novoAluno;
  }

  @override
  Future<Aluno> atualizar(Aluno aluno) async {
    final index = _alunos.indexWhere((a) => a.id == aluno.id);
    if (index == -1) {
      throw StateError('Aluno com id ${aluno.id} não encontrado.');
    }
    _alunos[index] = aluno;
    return aluno;
  }

  @override
  Future<void> excluir(String id) async {
    _alunos.removeWhere((aluno) => aluno.id == id);
  }

  String _gerarProximoId() {
    final maiorId = _alunos.fold<int>(
      0,
      (max, a) => int.tryParse(a.id) != null && int.parse(a.id) > max
          ? int.parse(a.id)
          : max,
    );
    return (maiorId + 1).toString();
  }
}
