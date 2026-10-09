import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../widgets/resposta_item.dart';

class DuvidaPage extends StatefulWidget {
  final String duvidaId;

  const DuvidaPage({
    super.key,
    required this.duvidaId,
  });

  @override
  State<DuvidaPage> createState() => _DuvidaPageState();
}

class _DuvidaPageState extends State<DuvidaPage> {
  final respostaController = TextEditingController();
  final service = FirestoreService();

  String? respostaPara;
  String? nomeResposta;

  bool apagando = false;

  @override
  void dispose() {
    respostaController.dispose();
    super.dispose();
  }

  Future<void> enviarResposta() async {
    final texto = respostaController.text.trim();

    if (texto.isEmpty) {
      return;
    }

    try {
      await service.responderDuvida(
        duvidaId: widget.duvidaId,
        texto: texto,
        respostaPara: respostaPara,
      );

      respostaController.clear();

      if (!mounted) {
        return;
      }

      setState(() {
        respostaPara = null;
        nomeResposta = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao responder: $e',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Apagar dúvida?',
          ),
          content: const Text(
            'Tem certeza que deseja apagar esta dúvida?\n\n'
            'Todas as respostas também serão apagadas. '
            'Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Apagar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      apagando = true;
    });

    try {
      await service.apagarDuvida(
        widget.duvidaId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dúvida apagada com sucesso.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        apagando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao apagar: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duvidaRef = FirebaseFirestore.instance
        .collection('duvidas')
        .doc(widget.duvidaId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dúvida'),

        // BOTÃO DE APAGAR
        actions: [
          IconButton(
            tooltip: 'Apagar dúvida',
            onPressed: apagando
                ? null
                : _confirmarExclusao,
            icon: apagando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                DocumentSnapshot<Map<String, dynamic>>>(
              stream: duvidaRef.snapshots(),
              builder: (
                context,
                duvidaSnapshot,
              ) {
                if (duvidaSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${duvidaSnapshot.error}',
                    ),
                  );
                }

                if (!duvidaSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final duvida =
                    duvidaSnapshot.data!.data();

                if (duvida == null) {
                  return const Center(
                    child: Text(
                      'Esta dúvida não existe mais.',
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Chip(
                      label: Text(
                        duvida['materia'] ?? 'Outras',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      duvida['titulo'] ?? '',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      duvida['descricao'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pergunta de '
                      '${duvida['autorNome'] ?? 'Aluno'}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const Divider(
                      height: 35,
                    ),

                    const Text(
                      'Respostas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: duvidaRef
                          .collection('respostas')
                          .orderBy('criadoEm')
                          .snapshots(),
                      builder: (
                        context,
                        respostaSnapshot,
                      ) {
                        if (respostaSnapshot.hasError) {
                          return Text(
                            'Erro: ${respostaSnapshot.error}',
                          );
                        }

                        if (!respostaSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final respostas =
                            respostaSnapshot.data!.docs;

                        if (respostas.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            child: Text(
                              'Ainda não há respostas. '
                              'Seja o primeiro!',
                            ),
                          );
                        }

                        return _montarRespostas(
                          respostas,
                          null,
                          0,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // MOSTRA QUEM ESTÁ SENDO RESPONDIDO
          if (nomeResposta != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                8,
                8,
              ),
              color: Colors.indigo.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Respondendo a $nomeResposta',
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        respostaPara = null;
                        nomeResposta = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
            ),

          // CAMPO DE RESPOSTA
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: respostaController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Escreva uma resposta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.filled(
                  onPressed:
                      apagando ? null : enviarResposta,
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _montarRespostas(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        respostas,
    String? paiId,
    int nivel,
  ) {
    final atuais = respostas.where((doc) {
      return doc.data()['respostaPara'] == paiId;
    }).toList();

    return Column(
      children: atuais.map((doc) {
        final dados = doc.data();

        return RespostaItem(
          autor: dados['autorNome'] ?? 'Aluno',
          texto: dados['texto'] ?? '',
          nivel: nivel,
          onResponder: () {
            setState(() {
              respostaPara = doc.id;
              nomeResposta =
                  dados['autorNome'] ?? 'Aluno';
            });
          },
          filhos: _montarRespostas(
            respostas,
            doc.id,
            nivel + 1,
          ),
        );
      }).toList(),
    );
  }
}