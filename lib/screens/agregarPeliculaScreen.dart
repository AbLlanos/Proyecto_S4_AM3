import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Agregarpeliculascreen extends StatelessWidget {
  const Agregarpeliculascreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Añadir pelicula")),

      body: formularioAgregarPelicula(context),
    );
  }
}

Widget formularioAgregarPelicula(BuildContext context) {
  TextEditingController codigo = TextEditingController();
  TextEditingController urlPortada = TextEditingController();
  TextEditingController titulo = TextEditingController();
  TextEditingController descripcion = TextEditingController();
  TextEditingController duracion = TextEditingController();
  TextEditingController edadRecomendada = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController urlVideo = TextEditingController();
  TextEditingController urlTrailer = TextEditingController();

  const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
  const Color labelColor = Colors.white;

  return SingleChildScrollView(
    child: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://i.pinimg.com/736x/53/71/15/5371158587b9381f6703e6a753db657f.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "Agregar película",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Center(
              child: Text(
                "Debe llenar los siguientes espacios obligatoriamente",
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(226, 226, 226, 1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Portada
            TextField(
              controller: codigo,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.image, color: Colors.white70),
                border: OutlineInputBorder(),
                labelText: "Codigo de la película",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Portada
            TextField(
              controller: urlPortada,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.image, color: Colors.white70),
                border: OutlineInputBorder(),
                labelText: "URL de la portada",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            TextField(
              controller: titulo,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.movie, color: Colors.white70),
                border: OutlineInputBorder(),
                labelText: "Título de la película",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Descripción
            TextField(
              controller: descripcion,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.description,
                  color: Colors.white70,
                ),
                border: OutlineInputBorder(),
                labelText: "Descripción",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Duración
            TextField(
              controller: duracion,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.timer, color: Colors.white70),
                border: OutlineInputBorder(),
                labelText: "Duración (min)",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Edad recomendada
            TextField(
              controller: edadRecomendada,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.confirmation_number,
                  color: Colors.white70,
                ),
                border: OutlineInputBorder(),
                labelText: "Edad recomendada",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // Año
            TextField(
              controller: year,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.date_range, color: Colors.white70),
                border: OutlineInputBorder(),
                labelText: "Año",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // URL Video
            TextField(
              controller: urlVideo,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.play_circle,
                  color: Colors.white70,
                ),
                border: OutlineInputBorder(),
                labelText: "URL Video",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),

            // URL Trailer
            TextField(
              controller: urlTrailer,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.video_library,
                  color: Colors.white70,
                ),
                border: OutlineInputBorder(),
                labelText: "URL Trailer",
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => guardarPelicula(
                  context,
                  codigo,
                  urlPortada,
                  titulo,
                  descripcion,
                  duracion,
                  edadRecomendada,
                  year,
                  urlVideo,
                  urlTrailer,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 110, 31, 93),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Agregar Película',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> guardarPelicula(
  BuildContext context,
  TextEditingController id,
  TextEditingController urlPortada,
  TextEditingController titulo,
  TextEditingController descripcion,
  TextEditingController duracion,
  TextEditingController edadRecomendada,
  TextEditingController year,
  TextEditingController urlVideo,
  TextEditingController urlTrailer,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión')));
    return;
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref(
    "usuarios/${user.uid}/peliculas/${id.text.trim()}",
  );

  await ref.set({
    "portada": urlPortada.text.trim(),
    "titulo": titulo.text.trim(),
    "descripcion": descripcion.text.trim(),
    "duracion": duracion.text.trim(),
    "edadRecomendada": edadRecomendada.text.trim(),
    "year": year.text.trim(),
    "video": urlVideo.text.trim(),
    "trailer": urlTrailer.text.trim(),
    "creadoPor": user.uid,
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Éxito'),
        content: const Text('Película agregada correctamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
