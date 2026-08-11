import 'package:flutter/foundation.dart';

class ContadorViewModel {
  final contador = ValueNotifier<int>(0);

  void incrementar() {
    contador.value++;
  }

  void dispose() {
    contador.dispose();
  }
}
