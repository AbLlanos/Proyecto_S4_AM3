import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
Future<List<Map<String, dynamic>>> leerPeliculasUsuario() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final snapshot = await FirebaseDatabase.instance
      .ref('usuarios/${user.uid}/peliculas')
      .get();

  print('snapshot.exists = ${snapshot.exists}');
  print('snapshot.value = ${snapshot.value}');

  if (!snapshot.exists || snapshot.value == null) return [];

  final rawList = List.from(snapshot.value as List);

  final List<Map<String, dynamic>> peliculas = [];
  for (int i = 0; i < rawList.length; i++) {
    final value = rawList[i];
    if (value == null) continue;

    final peli = Map<String, dynamic>.from(value as Map);
    peliculas.add({
      'id': i.toString(),
      'titulo': peli['titulo'],
      'anio': peli['year'],
      'image': peli['portada'],
      'descripcion': peli['descripcion'],
      'trailer': peli['trailer'],
      'pelicula': peli['video'],
    });
  }

  print('peliculas length = ${peliculas.length}');
  return peliculas;
}

// lista
Widget Listar(BuildContext context) {
  return Container(
    color: Colors.black,
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: leerPeliculasUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                          errorBuilder: (context, error, stack) =>
                              Container(height: 180, color: Colors.grey[800]),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // BOTONES EDITAR / ELIMINAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _mostrarDialogoEditar(context, item),
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            label: const Text(
                              'Editar',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _eliminarPelicula(context, item),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
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

//Funcion para eliminar
Future<void> _eliminarPelicula(
  BuildContext context,
  Map<String, dynamic> item,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final id = item['id']; // viene de leerPeliculasUsuario()
  final ref = FirebaseDatabase.instance.ref(
    'usuarios/${user.uid}/peliculas/$id',
  );

  await ref.remove();

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Película eliminada')));

  // Forzar rebuild de la pantalla actual
  (context as Element).reassemble();
}

//Funcion para editar

void _mostrarDialogoEditar(BuildContext context, Map<String, dynamic> item) {
  final TextEditingController tituloCtrl = TextEditingController(
    text: item['titulo'] ?? '',
  );
  final TextEditingController anioCtrl = TextEditingController(
    text: item['anio']?.toString() ?? '',
  );
  final TextEditingController portadaCtrl = TextEditingController(
    text: item['image'] ?? '',
  );
  final TextEditingController descCtrl = TextEditingController(
    text: item['descripcion'] ?? '',
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Editar película',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: anioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: portadaCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL portada',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancelar
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _guardarEdicionPelicula(
                context,
                item['id'],
                tituloCtrl.text.trim(),
                anioCtrl.text.trim(),
                portadaCtrl.text.trim(),
                descCtrl.text.trim(),
              );
              Navigator.of(context).pop(); // cierra diálogo
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      );
    },
  );
}

Future<void> _guardarEdicionPelicula(
  BuildContext context,
  String id,
  String titulo,
  String anio,
  String portada,
  String descripcion,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final ref = FirebaseDatabase.instance.ref(
    'usuarios/${user.uid}/peliculas/$id',
  );

  await ref.update({
    'titulo': titulo,
    'year': anio,
    'portada': portada,
    'descripcion': descripcion,
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Éxito'),
        content: const Text('Película actualizada correctamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );

  // Forzar rebuild de la lista
  (context as Element).reassemble();
}

//Modal para mostrar detalles de la pelicula
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
  const DetalleModal({super.key, required this.pelicula});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) print('No se pudo abrir: $uri');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Colors.black),
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
