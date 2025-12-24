import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  Map<String, dynamic>? usuarioData;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

Future<void> _cargarDatosUsuario() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final snapshot = await FirebaseDatabase.instance
        .ref('usuarios/${user.uid}')
        .get();

    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(
        snapshot.value as Map, 
      );

      setState(() {
        usuarioData = data;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack( 
        children: [

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://i.postimg.cc/LsXq5Nsw-/IMG-20240104-120318.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: const Color(0xAA000000)),  
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO
                  const Center(
                    child: Text(
                      "VixDocumentary",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // INSTRUCCIÓN
                  const Center(
                    child: Text(
                      "Datos del usuario",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(226, 226, 226, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    constraints: const BoxConstraints(maxWidth: 350),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(197, 116, 116, 116),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [

                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color.fromARGB(255, 110, 31, 93),
                          child: Text(
                            usuarioData?['nombre']?[0]?.toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // NOMBRE COMPLETO
                        Text(
                          '${usuarioData?['nombre'] ?? ''} ${usuarioData?['apellido'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // CORREO
                        Text(
                          usuarioData?['correo'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // TELÉFONO Y PAÍS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              usuarioData?['telefono'] ?? '',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.public, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              usuarioData?['pais'] ?? '',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nacimiento: ${usuarioData?['fechaNacimiento'] ?? ''}',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTONES
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/catalogo'),
                      icon: const Icon(Icons.movie, color: Colors.white),
                      label: const Text(
                        'Ver Mis Películas',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/agregarPelicula'),
                      icon: const Icon(Icons.movie, color: Colors.white),
                      label: const Text(
                        'Agregar Película',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 167, 45, 158),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
