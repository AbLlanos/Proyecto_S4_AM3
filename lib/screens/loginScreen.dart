import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/screens/catalogoScreen.dart';
import 'package:proyecto_s4_am3/screens/registroScreen.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
        elevation: 0,
      ),
      body: const Cuerpo(),
    );
  }
}

class Cuerpo extends StatelessWidget {
  const Cuerpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con imagen
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://i.postimg.cc/LsXq5Nsw-/IMG-20240104-120318.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: Color(0xAA000000)),
        ),

        // Contenido simple
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "VixDocumentary",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
                const Text(
                  'Ingrese sus credenciales',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(200, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 20),

                // Correo
                const _CampoTexto(
                  label: 'Correo electrónico',
                  icon: Icons.email,
                  teclado: TextInputType.emailAddress,
                  esPassword: false,
                ),
                const SizedBox(height: 12),

                // Contraseña
                const _CampoTexto(
                  label: 'Contraseña',
                  icon: Icons.lock,
                  teclado: TextInputType.text,
                  esPassword: true,
                ),
                const SizedBox(height: 20),

                // Botón Entrar
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 43, 12, 41),
                    ),
                    onPressed: () => irPantallaCatalago(context),
                    child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                  ),
                ),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No tienes una cuenta?",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                      ),
                      TextButton(
                        onPressed: () => irPantallaRegistro(context),
                        child: Text("Registrarse"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextInputType teclado;
  final bool esPassword;

  const _CampoTexto({
    required this.label,
    required this.icon,
    required this.teclado,
    required this.esPassword,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: teclado,
      obscureText: esPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
    );
  }
}

void irPantallaCatalago(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => catalogoScreen()),
  );
}

void irPantallaRegistro(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => registroScreen()),
  );
}
