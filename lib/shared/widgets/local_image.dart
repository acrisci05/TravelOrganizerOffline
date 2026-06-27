import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Mostra un'immagine salvata in locale (foto del diario di viaggio).
// Su dispositivi mobili/desktop il percorso è un file, su Web è un blob URL:
// il widget sceglie automaticamente il modo corretto di caricare l'immagine e,
// in caso di errore (file mancante), mostra un'icona di riserva.
class LocalImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LocalImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  // Riquadro di riserva mostrato se l'immagine non può essere caricata.
  Widget _fallback(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Su Web il percorso è un URL (blob) caricabile come immagine di rete.
      return Image.network(path,
          width: width, height: height, fit: fit, errorBuilder: _fallback);
    }
    // Su mobile/desktop il percorso è un file locale.
    return Image.file(File(path),
        width: width, height: height, fit: fit, errorBuilder: _fallback);
  }
}
