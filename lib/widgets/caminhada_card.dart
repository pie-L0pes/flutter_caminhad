import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/caminhada.dart';

class CaminhadaCard extends StatelessWidget {
  final Caminhada caminhada;
  final VoidCallback onTap;

  const CaminhadaCard({
    super.key,
    required this.caminhada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 105,
              height: 115,
              child: caminhada.fotoPath != null &&
                      File(caminhada.fotoPath!).existsSync()
                  ? Image.file(
                      File(caminhada.fotoPath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.directions_walk,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caminhada.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(caminhada.data),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.straighten, size: 17),
                        const SizedBox(width: 4),
                        Text('${caminhada.distanciaKm.toStringAsFixed(2)} km'),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_outlined, size: 17),
                        const SizedBox(width: 4),
                        Text('${caminhada.tempoMinutos} min'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
