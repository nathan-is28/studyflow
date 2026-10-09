import 'package:flutter/material.dart';

class RespostaItem extends StatelessWidget {
  final String autor;
  final String texto;
  final int nivel;
  final VoidCallback onResponder;
  final Widget? filhos;

  const RespostaItem({
    super.key,
    required this.autor,
    required this.texto,
    required this.nivel,
    required this.onResponder,
    this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: nivel * 20.0,
        bottom: 10,
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                autor,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(texto),
              TextButton.icon(
                onPressed: onResponder,
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Responder'),
              ),
              if (filhos != null) filhos!,
            ],
          ),
        ),
      ),
    );
  }
}
