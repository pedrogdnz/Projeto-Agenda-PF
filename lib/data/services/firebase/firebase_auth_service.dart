import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:agendapf/data/services/abstract/auth_data_source.dart';

class FirebaseAuthService implements AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _initialized = false;

  Future<void> _garantirInicializado() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId:
          '356248465632-vl9e60da1fvh81cv7tn1s5c40sqq02uu.apps.googleusercontent.com',
    );
    _initialized = true;
  }

  @override
  Stream<UsuarioGoogle?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UsuarioGoogle(
        uid: user.uid,
        nome: user.displayName ?? '',
        email: user.email ?? '',
      );
    });
  }

  @override
  Future<UsuarioGoogle> signInWithGoogle() async {
    await _garantirInicializado();

    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const LoginCanceladoException();
      }
      rethrow;
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) throw const LoginCanceladoException();

    return UsuarioGoogle(
      uid: firebaseUser.uid,
      nome: firebaseUser.displayName ?? googleUser.displayName ?? '',
      email: firebaseUser.email ?? googleUser.email,
    );
  }

  @override
  Future<UsuarioGoogle> signInComEmail({
    required String email,
    required String senha,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final user = credential.user;
      if (user == null) throw const CredenciaisInvalidasAuthException();

      return UsuarioGoogle(
        uid: user.uid,
        nome: user.displayName ?? '',
        email: user.email ?? email,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapearErro(e);
    }
  }

  @override
  Future<UsuarioGoogle> cadastrarComEmail({
    required String email,
    required String senha,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final user = credential.user;
      if (user == null) throw const CredenciaisInvalidasAuthException();

      return UsuarioGoogle(uid: user.uid, nome: '', email: user.email ?? email);
    } on FirebaseAuthException catch (e) {
      throw _mapearErro(e);
    }
  }

  @override
  Future<void> excluirContaAtual() async {
    await _auth.currentUser?.delete();
  }

  Exception _mapearErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const CredenciaisInvalidasAuthException();
      case 'email-already-in-use':
        return const EmailJaCadastradoAuthException();
      case 'weak-password':
        return const SenhaFracaException();
      default:
        return Exception('Erro ao autenticar: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}