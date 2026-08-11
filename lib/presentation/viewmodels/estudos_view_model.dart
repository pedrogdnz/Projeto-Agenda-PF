import 'package:flutter/foundation.dart';

class EstudosViewModel extends ChangeNotifier {
  int _contador = 0;
  bool _carregando = false;

  int get contador => _contador;
  bool get carregando => _carregando;

  Future<void> incrementar() async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _contador++;
    _carregando = false;
    notifyListeners();
  }
}
