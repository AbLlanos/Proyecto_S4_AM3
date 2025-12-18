import 'dart:convert';
import 'package:flutter/material.dart';

class catalogoScreen extends StatelessWidget {
  const catalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo disponible")),
      body: Listar(context),
    );
  }
}

// json
Future<List> leerLista(context) async {
  final jsonString = await DefaultAssetBundle.of(context)
      .loadString("assets/data/peliculas1.json");
  return json.decode(jsonString)['peliculas'];
}

// lista
Widget Listar(context) {
  return FutureBuilder(
    future: leerLista(context),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasData) {
        final data = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetallePeliculaScreen(pelicula: item),
                  ),
                );
              },
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FILA: Título arriba con año al lado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['titulo'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${item['anio'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // IMAGEN ocupando todo el ancho del Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image'] ?? '',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              Container(
                                  height: 180, color: Colors.grey[300]),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // DESCRIPCIÓN debajo
                      Text(
                        item['descripcion'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return const Center(child: Text("No hay data"));
      }
    },
  );
}

// ======= DETALLE TIPO NETFLIX =======
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
            // Portada grande
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                pelicula['image'] ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                pelicula['descripcion'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    // Aquí podrías abrir la URL (pelicula['url']) con url_launcher
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
