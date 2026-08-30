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
      // Web Client ID (do Google Cloud Console / Firebase Console).
      // Necessário mesmo em Android/iOS a partir da v7.
      serverClientId: 'SEU_WEB_CLIENT_ID.apps.googleusercontent.com',
    );
    _initialized = true;
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
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}