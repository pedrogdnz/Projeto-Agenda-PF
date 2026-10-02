import 'package:agendapf/data/models/disponibilidade_padrao_model.dart';
import 'package:agendapf/data/models/enum/dia_semana.dart';

abstract class DisponibilidadePadraoService {
  Future<List<DisponibilidadePadrao>> buscarTodas();
  Future<DisponibilidadePadrao?> buscarPorId(String id);
  Future<DisponibilidadePadrao?> buscarPorDia(DiaSemana diaSemana);
  Future<DisponibilidadePadrao> criar(DisponibilidadePadrao disponibilidade);
  Future<DisponibilidadePadrao> atualizar(
    DisponibilidadePadrao disponibilidade,
  );
  Future<void> excluir(String id);
}
