import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/screens/catalogoScreen.dart';
import 'package:proyecto_s4_am3/screens/loginScreen.dart';
import 'package:proyecto_s4_am3/screens/registroScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VixDocumentaryApp());
}

class VixDocumentaryApp extends StatelessWidget {
  const VixDocumentaryApp({super.key});
  @override
  Widget build(BuildContext context) => 
  MaterialApp(

    routes: {
      '/login': (context) => loginScreen(),
      '/registro': (context) => registroScreen(),
      '/catalogo': (context) => catalogoScreen(),
    },


    title: 'VixDocumentary',
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
        'VixDocumentary',
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

    //Drawer
    drawer: Drawer(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.purple[100],
            child: Center(
              child: Text(
                "VixDocumentary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.login, color: Colors.purple),
            title: Text("Login"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => loginScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.video_library, color: Colors.purple),
            title: Text("Registrarse"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => registroScreen()),
              );
            },
          ),
        ],
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
                      '¡Bienvenido a VixDocumentary!',
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

                    SizedBox(
                      height: 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            TrendImage(
                              index: 1,
                              url:
                                  'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABfORJGAy9lFPC7YKGR1XLmX50b9BNRgsKrsLHE1nZdWcYHaba8RURaC3S8vRYpgaPnAV9vIjI8xzuAhhwg4qjwinwU5qoZqIkR0.jpg?r=890',
                            ),
                            SizedBox(width: 12),
                            TrendImage(
                              index: 2,
                              url:
                                  'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABfjOaHOS18IrQN3YbT52YmkuGx0VZUmiJYRT7mZA-MYoQEN8U7Bcq-KEcPC9E9VZt00y6zoiAJ69G9zwIX5WliwE3-TE9qdkm-g.jpg?r=6d5',
                            ),
                            SizedBox(width: 12),
                            TrendImage(
                              index: 3,
                              url:
                                  'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABRSSnW8MlbjYqQrNp2jS0VEKom5SWGW1sa96Zc8RpHzFaSrTZZ5WV_ExuxFPW94wwIPn9cwxkq0mXBL2U7Cv-Wiwevti3OvHPVE.jpg?r=fd2',
                            ),
                            SizedBox(width: 12),
                            TrendImage(
                              index: 4,
                              url:
                                  'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABQUzlnPyt9wOXquyWW3G3ZXjBi4Hof0lhlv8TtHN4mE6t8vDCd1T1lk8MxURwdYyfeCcl2CcIDCruTvOPbJdxV8y1eRbFnuw1cY.jpg?r=f93',
                            ),
                            SizedBox(width: 12),
                            TrendImage(
                              index: 5,
                              url:
                                  'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABetUJ9QNi10AAp_pEyZ6PVJ2II7TZA9w1ZQGNftL1V383nmvVmEKTVvh8a17akqxT-7HodJ6iQr1W20KhffN7Q_ZWiSK9PF4IFc.jpg?r=479',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nuestras recomendaciones (igual que tenías)
              Container(
                color: const Color(0xFF2A2A2A),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.recommend, color: Colors.orange, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Nuestras recomendaciones',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: const [
                        RecoImage(
                          url:
                              'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABYg1gztA49i15Ed0w2uWX8ecLG4Ojih_OeMZ5V-kOXVEz16kywp9CqcaJxMa63faFdxyttChnheIxy3I37Dj7iSK2wwocB0sUjE.jpg?r=039',
                          titulo: 'El caso Watts: El padre homicida',
                        ),
                        RecoImage(
                          url:
                              'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABe__2wFZ0vkus5CLSPgAcz5iys8h1gweSD-PPBp171Fzc-2umLX06jSvmKtmQE3eBfQjBBZh3ZLJULzS2t7i30ZdDoePEvmYvnE.jpg?r=e4c',
                          titulo: 'Una vida suprema',
                        ),
                        RecoImage(
                          url:
                              'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABbHOB86urT2CZq-2jD_LkCFEdtIziOtDsXoHKFx5QLUVl1o79s3IIcAwU6r9tuJwDg8kcLB5DXUrZkpZOdXAz0jftECrNySElu4.jpg?r=bd2',
                          titulo: 'Colin en blanco y negro',
                        ),
                        RecoImage(
                          url:
                              'https://occ-0-7309-1380.1.nflxso.net/dnm/api/v6/Qs00mKCpRvrkl3HZAN5KwEL1kpE/AAAABVclh_x7Nbe5YO-vwQn2A6Hf4CC55pNX6S7UtC4nW62DrRqtbTsW2Q35zkRVfSAiEyp6QAOWGL56Z4dTyO4OiHvHz1gGnFHPiCA.jpg?r=abc',
                          titulo: 'La gran noche del pop',
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
                          'soporte@VixDocumentary.com',
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
                          '2025 VixDocumentary',
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
