import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _nomeUsuario() async {
    final user = _auth.currentUser!;

    final doc = await _db
        .collection('usuarios')
        .doc(user.uid)
        .get();

    return (doc.data()?['nome'] as String?) ??
        user.displayName ??
        'Aluno';
  }

  Future<void> criarDuvida({
    required String titulo,
    required String descricao,
    required String materia,
  }) async {
    final user = _auth.currentUser!;
    final nome = await _nomeUsuario();

    await _db.collection('duvidas').add({
      'titulo': titulo,
      'descricao': descricao,
      'materia': materia,
      'autorId': user.uid,
      'autorNome': nome,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> responderDuvida({
    required String duvidaId,
    required String texto,
    String? respostaPara,
  }) async {
    final user = _auth.currentUser!;
    final nome = await _nomeUsuario();

    await _db
        .collection('duvidas')
        .doc(duvidaId)
        .collection('respostas')
        .add({
      'texto': texto,
      'autorId': user.uid,
      'autorNome': nome,
      'respostaPara': respostaPara,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> apagarDuvida(String duvidaId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Usuário não está logado.',
      );
    }

    final duvidaRef = _db
        .collection('duvidas')
        .doc(duvidaId);

    final duvidaSnapshot =
        await duvidaRef.get();

    if (!duvidaSnapshot.exists) {
      throw Exception(
        'Esta dúvida não existe mais.',
      );
    }

    final dados = duvidaSnapshot.data();

    final autorId = dados?['autorId']?.toString();

    if (autorId != user.uid) {
      throw Exception(
        'Você não pode apagar uma dúvida que não é sua.',
      );
    }

    final respostasSnapshot = await duvidaRef
        .collection('respostas')
        .get();

    final batch = _db.batch();

    for (final resposta
        in respostasSnapshot.docs) {
      batch.delete(resposta.reference);
    }

    batch.delete(duvidaRef);

    await batch.commit();
  }
}

