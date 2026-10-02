class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Digite uma senha.';
    }

    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve conter uma letra maiúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'A senha deve conter um número.';
    }

    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      return 'A senha deve conter um caractere especial.';
    }

    return null;
  }

  static bool isValid(String password) {
    return validate(password) == null;
  }
}
