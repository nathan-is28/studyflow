import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/duvida_card.dart';
import 'criar_duvida_page.dart';
import 'duvida_page.dart';
import 'login_page.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String materiaSelecionada = 'Todas';
  String pesquisa = '';

  final materias = const [
    'Todas',
    'Matemática',
    'Português',
    'Física',
    'Química',
    'Biologia',
    'História',
    'Geografia',
    'Inglês',
    'Tecnologia',
    'Outras',
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> _streamDuvidas() {
    if (materiaSelecionada == 'Todas') {
      return FirebaseFirestore.instance
          .collection('duvidas')
          .orderBy('criadoEm', descending: true)
          .snapshots();
    }

    // CONSULTA/FILTRO 1
    return FirebaseFirestore.instance
        .collection('duvidas')
        .where('materia', isEqualTo: materiaSelecionada)
        .snapshots();
  }

  Future<void> _sair() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StudyFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Meu perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilPage()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (valor) {
                setState(() => pesquisa = valor.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar dúvidas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: pesquisa.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() => pesquisa = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: materias.length,
              itemBuilder: (context, index) {
                final materia = materias[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(materia),
                    selected: materia == materiaSelecionada,
                    onSelected: (_) {
                      setState(() => materiaSelecionada = materia);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _streamDuvidas(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Não foi possível carregar as dúvidas.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                final filtradas = docs.where((doc) {
                  if (pesquisa.isEmpty) return true;

                  final dados = doc.data();
                  final titulo =
                      (dados['titulo'] ?? '').toString().toLowerCase();
                  final descricao =
                      (dados['descricao'] ?? '').toString().toLowerCase();
                  final autor =
                      (dados['autorNome'] ?? '').toString().toLowerCase();

                  return titulo.contains(pesquisa) ||
                      descricao.contains(pesquisa) ||
                      autor.contains(pesquisa);
                }).toList();

                if (filtradas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma dúvida encontrada.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final doc = filtradas[index];
                    final dados = doc.data();

                    return DuvidaCard(
                      titulo: dados['titulo'] ?? '',
                      descricao: dados['descricao'] ?? '',
                      materia: dados['materia'] ?? 'Outras',
                      autor: dados['autorNome'] ?? 'Aluno',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DuvidaPage(duvidaId: doc.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CriarDuvidaPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova dúvida'),
      ),
    );
  }
}
