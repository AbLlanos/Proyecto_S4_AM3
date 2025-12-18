import 'package:flutter/material.dart';

class DetallePeliculaScreen extends StatelessWidget {
  final Map pelicula;

  const DetallePeliculaScreen({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(pelicula['titulo'] ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada grande optimizada
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                pelicula['image'] ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(height: 12),

            // Año + badge HD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "${pelicula['anio'] ?? ''}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.hd, color: Colors.white70, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Descripción completa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                pelicula['descripcion'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Botón tipo Netflix
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    // Aquí podrías abrir pelicula['url'] con url_launcher
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Reproducir"),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
