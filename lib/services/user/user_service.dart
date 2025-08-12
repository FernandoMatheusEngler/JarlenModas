import 'package:firebase_auth/firebase_auth.dart';
import 'package:jarlenmodas/utils/auth_exception.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> createUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      throw AuthException('Erro inesperado ao criar usuário: ${e.toString()}');
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code), errorCode: e.code);
    } catch (e) {
      throw AuthException('Erro inesperado ao fazer login: ${e.toString()}');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Usuário ou senha inválidos, verifique as informações digitadas.';
      case 'wrong-password':
        return 'Usuário ou senha inválidos, verifique as informações digitadas.';
      case 'unknown-error':
        return 'Usuário ou senha inválidos, verifique as informações digitadas.';
      case 'invalid-email':
        return 'E-mail inválido, verifique o e-mail digitado.';
      default:
        return 'Erro desconhecido: $errorCode';
    }
  }
}
