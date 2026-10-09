import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class CriarDuvidaPage extends StatefulWidget {
  const CriarDuvidaPage({super.key});

  @override
  State<CriarDuvidaPage> createState() => _CriarDuvidaPageState();
}

class _CriarDuvidaPageState extends State<CriarDuvidaPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final service = FirestoreService();

  String materia = 'Matemática';
  bool carregando = false;

  final materias = const [
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

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> publicar() async {
    if (tituloController.text.trim().isEmpty ||
        descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      await service.criarDuvida(
        titulo: tituloController.text.trim(),
        descricao: descricaoController.text.trim(),
        materia: materia,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova dúvida')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título da dúvida',
                hintText: 'Ex.: Como resolver uma equação do 2º grau?',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: materia,
              decoration: const InputDecoration(
                labelText: 'Matéria',
              ),
              items: materias.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => materia = valor);
                }
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TextField(
                controller: descricaoController,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Explique sua dúvida',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: carregando ? null : publicar,
                icon: const Icon(Icons.send),
                label: Text(
                  carregando ? 'Publicando...' : 'Publicar dúvida',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
