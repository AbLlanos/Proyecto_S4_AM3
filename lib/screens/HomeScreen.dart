import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // SELECT * FROM usuarios WHERE id = user.id LIMIT 1
    final response = await supabase
        .from('usuariosVix')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        usuarioData = Map<String, dynamic>.from(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer (sin cambios)
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.purple[100],
              child: Center(
                child: Text(
                  "VixScienceMov",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.purple),
              title: const Text("Home"),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_add, color: Colors.purple),
              title: const Text("Revisar cátalogo"),
              onTap: () {
                Navigator.pushNamed(context, '/catalogo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.purple),
              title: const Text("Agregar película"),
              onTap: () {
                Navigator.pushNamed(context, '/agregarPelicula');
              },
            ),
          ],
        ),
      ),

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
            onPressed: () async {
              await supabase.auth.signOut();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¡Sesión cerrada!'),
                  content: const Text(
                    'Sesión cerrada exitosamente',
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
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
                  'https://i.pinimg.com/564x/a5/d3/f2/a5d3f2a854a4c14780d849710aae38f9.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: const Color.fromARGB(122, 0, 0, 0)),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                
                children: [
                  const Center(
                    child: Text(
                      "VixScienceMov",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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

                  // CONTAINER PRINCIPAL CON FOTO 
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
                        // FOTO DE PERFIL NUEVA 
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: usuarioData?['perfil_url'] != null &&
                                    usuarioData!['perfil_url'].isNotEmpty
                                ? Image.network(
                                    usuarioData!['perfil_url'],
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white70,
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white70,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // NOMBRE (debajo de la foto)
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
                        Text(
                          usuarioData?['correo'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              usuarioData?['telefono'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.public,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              usuarioData?['pais'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nacimiento: ${usuarioData?['fecha_nacimiento'] ?? usuarioData?['fechaNacimiento'] ?? ''}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTONES (sin cambios)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/catalogo'),
                      icon: const Icon(Icons.movie, color: Colors.white),
                      label: const Text(
                        'Revisar catálogo',
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
                        'Agregar nuevas películas',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 167, 45, 158),
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
