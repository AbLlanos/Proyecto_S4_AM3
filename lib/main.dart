import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/screens/catalogoUsuarioScreen.dart';
import 'package:proyecto_s4_am3/screens/editarDatosVideoScreen.dart';
import 'package:proyecto_s4_am3/screens/homeScreen.dart';
import 'package:proyecto_s4_am3/screens/agregarPeliculaScreen.dart';
import 'package:proyecto_s4_am3/screens/catalogoScreen.dart';
import 'package:proyecto_s4_am3/screens/loginScreen.dart';
import 'package:proyecto_s4_am3/screens/registroScreen.dart';
/*
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
*/
import 'package:supabase_flutter/supabase_flutter.dart';

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

Future<void> main() async {
  /*
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VixScienceMovApp());

  Future<void> main() async {*/

  await Supabase.initialize(
    url: 'https://dbuieqmrxxwbtyfahijl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRidWllcW1yeHh3YnR5ZmFoaWpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzODY5MjQsImV4cCI6MjA4MTk2MjkyNH0.J6-r4u8ma4JF322fI-osU2_eW3TEpm72FpvXpBZiBV8',
  );

  runApp(VixScienceMovApp());
}

class VixScienceMovApp extends StatelessWidget {
  const VixScienceMovApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    routes: {
      '/login': (context) => loginScreen(),
      '/registro': (context) => registroScreen(),
      '/catalogo': (context) => catalogoScreen(),
      '/catalogoUsuario': (context) => catalogoUsuarioScreen(),
      '/agregarPelicula': (context) => Agregarpeliculascreen(),
      '/editarVideo': (context) => Editardatosvideoscreen(),
      '/home': (context) => homeScreen(),
    },

    title: 'VixScienceMov',
    home: const WelcomeScreen(),
    debugShowCheckedModeBanner: false,
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'VixScienceMov',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Color.fromRGBO(255, 255, 255, 0.541),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 110, 31, 93),
              Color.fromARGB(255, 49, 24, 38),
            ],
          ),
        ),
      ),
    ),

    body: Stack(
      children: [
        // FONDO
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://media.revistagq.com/photos/6013f55c83cfb236300a4694/16:9/w_1280,c_limit/star-disney-plus-catalogo.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: const Color(0xAA000000)),
        ),

        //
        SingleChildScrollView(
          child: Column(
            children: [
              // Saludo
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // ← ALINEA COLUMNA AL CENTRO
                  children: [
                    const Text(
                      '¡Bienvenido a VixScienceMov!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tu mundo de documentales favoritas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Botones
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => irPantallaLogin(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromARGB(255, 43, 12, 41),
                      ),
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    FilledButton(
                      onPressed: () => irPantallaRegistro(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromARGB(218, 66, 10, 66),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Tendencias
              Container(
                color: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.trending_up, color: Colors.red, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Tendencias',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Carrusel de tendencias
                    SizedBox(
                      height: 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const TrendImage(
                                index: 1,
                                url:
                                    'https://m.media-amazon.com/images/M/MV5BMjEwMzMxODIzOV5BMl5BanBnXkFtZTgwNzg3OTAzMDI@._V1_.jpg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const TrendImage(
                                index: 2,
                                url:
                                    'https://m.media-amazon.com/images/M/MV5BZmM3ZjE0NzctNjBiOC00MDZmLTgzMTUtNGVlOWFlOTNiZDJiXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const TrendImage(
                                index: 3,
                                url:
                                    'https://lumiere-a.akamaihd.net/v1/images/poster-avatar-2-lat_46034440_1_c359a2d2.png',
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const TrendImage(
                                index: 4,
                                url:
                                    'https://play-lh.googleusercontent.com/bsXfJQN4WNagbPiNclU-gLZZVFpOaRih7VJuse6F5cNiQpH778sLOMEYwbeDMdyOG8dj',
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const TrendImage(
                                index: 5,
                                url:
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTI-oweaXkYJRVA4OfXYcaYnzrLwPxXibFFIw&s',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              // Nuestras recomendaciones
              Container(
                color: const Color(0xFF2A2A2A),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.recommend,
                          color: Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: const Text(
                            'Nuestras recomendaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Grid de recomendaciones
                    // Grid de recomendaciones
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const RecoImage(
                            url:
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNrNiGixbF-X4j5ntDHc0E1ZY3l0Zd4k-cMw&s',
                            titulo: 'Star Wars: Episode V - The Empire Strikes Back ',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const RecoImage(
                            url:
                                'https://upload.wikimedia.org/wikipedia/en/thumb/c/cb/Alien_Romulus_2024_%28poster%29.jpg/250px-Alien_Romulus_2024_%28poster%29.jpg',
                            titulo: 'Alien: Romulus',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const RecoImage(
                            url:
                                'https://m.media-amazon.com/images/M/MV5BMjA1Nzk0OTM2OF5BMl5BanBnXkFtZTgwNjU2NjEwMDE@._V1_FMjpg_UX1000_.jpg',
                            titulo: 'Her',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const RecoImage(
                            url:
                                'https://es.web.img3.acsta.net/pictures/17/10/03/08/45/4260918.jpg',
                            titulo: 'Blade Runner 2049',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '+1 (555) 123-4567',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'soporte@VixScienceMov.com',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copyright, color: Colors.white54, size: 14),
                        SizedBox(width: 8),
                        Text(
                          '2025 VixScienceMov',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class TrendImage extends StatelessWidget {
  final String url;
  final int index;
  const TrendImage({super.key, required this.url, required this.index});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: 150,
        height: 250,
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 4)),
          ],
        ),
      ),
      Positioned(
        left: 8,
        bottom: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}

// Widget para recomendaciones
class RecoImage extends StatelessWidget {
  final String url;
  final String titulo;
  const RecoImage({super.key, required this.url, required this.titulo});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(child: Image.network(url, fit: BoxFit.cover)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Center(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void irPantallaLogin(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => loginScreen()),
  );
}

void irPantallaRegistro(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => registroScreen()),
  );
}
