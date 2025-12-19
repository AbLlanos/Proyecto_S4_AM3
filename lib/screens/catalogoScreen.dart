import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 

class catalogoScreen extends StatelessWidget {
  catalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catálogo disponible',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromRGBO(255, 255, 255, 0.835),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 110, 31, 93),
                Color.fromARGB(255, 49, 24, 38),
              ],
            ),
          ),
        ),
      ),

      body: Listar(context),
    );
  }
}

// json
Future<List> leerLista(context) async {
  final jsonString = await DefaultAssetBundle.of(
    context,
  ).loadString("assets/data/peliculas1.json");
  return json.decode(jsonString)['peliculas'];
}

// lista
Widget Listar(context) {
  return Container(
    
    color: Colors.black, 
    child: FutureBuilder(
      future: leerLista(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return GestureDetector(
                onTap: () => _mostrarDetalle(context, item),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  elevation: 8, 
                  color: Colors.grey[900], 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['titulo'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, 
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
                                color: Colors.white70, 
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? '',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: 180,
                              color: Colors
                                  .grey[800], 
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text("No hay data", style: TextStyle(color: Colors.white70)),
          );
        }
      },
    ),
  );
}

void _mostrarDetalle(BuildContext context, Map pelicula) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DetalleModal(pelicula: pelicula),
  );
}

class DetalleModal extends StatelessWidget {
  final Map pelicula;
  const DetalleModal({
    super.key,
    required this.pelicula,
  }); 

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) print('No se pudo abrir: $uri');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height, 
      decoration: const BoxDecoration(
        color: Colors.black,
      ), 
      child: ListView(
      
        padding: const EdgeInsets.all(16),
        children: [
          
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 16),
            child: Text(
              pelicula['titulo'] ?? '',
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              pelicula['image'] ?? '',
              width: double.infinity,
              height: 250, 
              fit: BoxFit.cover, 
              errorBuilder: (context, error, stack) =>
                  Container(height: 250, color: Colors.grey[800]),
            ),
          ),

          const SizedBox(height: 20),

          // AÑO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${pelicula['anio'] ?? ''}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.hd, color: Colors.white70, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // DESCRIPCIÓN (centrado)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              pelicula['descripcion'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÓN 1: TRAILER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  try {
                    final url = pelicula['trailer']?.toString();
                    if (url != null &&
                        url.isNotEmpty &&
                        url.startsWith('http')) {
                      final uri = Uri.parse(url);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tráiler no disponible')),
                      );
                    }
                  } catch (e) {
                    print('Error tráiler: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al abrir tráiler')),
                    );
                  }
                },
                icon: const Icon(Icons.ondemand_video),
                label: const Text('Mirar tráiler'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // BOTÓN 2: PELÍCULA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  try {
                    final url = pelicula['pelicula']?.toString();
                    if (url != null &&
                        url.isNotEmpty &&
                        url.startsWith('http')) {
                      final uri = Uri.parse(url);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Película no disponible')),
                      );
                    }
                  } catch (e) {
                    print('Error película: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al abrir película')),
                    );
                  }
                },
                icon: const Icon(Icons.movie),
                label: const Text(
                  'Ver película',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),

          // BOTÓN CERRAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cerrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
