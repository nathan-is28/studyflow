import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<String?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await credential.user!.updateDisplayName(nome);

      await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set({
        'nome': nome,
        'email': email,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _mensagemErro(e);
    }
  }

  Future<String?> login({
    required String email,
    required String senha,
    required bool manterLogin,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manterLogin', manterLogin);

      return null;
    } on FirebaseAuthException catch (e) {
      return _mensagemErro(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('manterLogin', false);
  }

  String _mensagemErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'network-request-failed':
        return 'Verifique sua conexão com a internet.';
      default:
        return e.message ?? 'Não foi possível realizar a operação.';
    }
  }
}
