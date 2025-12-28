//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:proyecto_s4_am3/screens/catalogoScreen.dart';
import 'package:proyecto_s4_am3/screens/registroScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class loginScreen extends StatelessWidget {
  const loginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: formularioRegistro(context),
          ),
        ),
      ],
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

//Formualrio de login

Widget formularioRegistro(context) {
  TextEditingController correoUsuario = TextEditingController();
  TextEditingController contraseniaUsuario = TextEditingController();

  const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
  const Color labelColor = Colors.white;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Center(
        child: Text(
          "VixVideo",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 20),

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
      const SizedBox(height: 32),

      TextField(
        controller: correoUsuario,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese el correo electrónico",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      const SizedBox(height: 20),

      TextField(
        controller: contraseniaUsuario,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese la contraseña",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      const SizedBox(height: 32),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => loginVixUsuarioSupabase(
            correoUsuario,
            contraseniaUsuario,
            context,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 110, 31, 93),
          ),
          child: const Text(
            'Iniciar Sesión',
            style: TextStyle(color: labelColor),
          ),
        ),
      ),
      const SizedBox(height: 16),

      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No tienes una cuenta?",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => irPantallaRegistro(context),
              child: const Text(
                "Registrarse",
                style: TextStyle(color: Color.fromARGB(255, 167, 45, 158)),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<void> loginVixUsuarioSupabase(correo, contrasenia, context) async {

  if (correo.text.isEmpty || contrasenia.text.isEmpty) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error de Login'),
          content: Text('Por favor complete todos los campos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  try {
    // 1. Iniciar sesión en Supabase Auth
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

    final user = res.user;
    if (user == null) {
      throw Exception('No se pudo iniciar sesión');
    }

    // 2. Navegar a /home
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: user.id,
    );

    } on AuthException catch (e) {

    final msg = e.message.toLowerCase();
    String mensaje;

    if (msg.contains('invalid login credentials')) {
      mensaje = 'Credenciales incorrectas.';
    } else if (msg.contains('email') && msg.contains('invalid')) {
      mensaje = 'Correo electrónico inválido.';
    } else if (msg.contains('email not confirmed')) {
      mensaje = 'Debe confirmar su correo electrónico antes de continuar.';
    } else if (msg.contains('rate limit')) {
      mensaje = 'Demasiados intentos. Intente nuevamente más tarde.';
    } else {
      mensaje = e.message;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Login'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error de conexión: $e'),
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
}



/*
Future<void> loginVixUsuario(correo, contrasenia, context) async {
  if (correo.text.isEmpty || contrasenia.text.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Login'),
          content: const Text('Por favor complete todos los campos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
    );

    // CARGAR DATOS DEL USUARIO y navegar
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: credential.user!.uid,
    );

    //Alertas de errores de login
  } on FirebaseAuthException catch (e) {
    String mensaje = 'Error desconocido';
    switch (e.code) {
      case 'user-not-found':
        mensaje = 'No existe cuenta con este correo.';
        break;
      case 'wrong-password':
        mensaje = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
        mensaje = 'Correo electrónico inválido.';
        break;
      case 'too-many-requests':
        mensaje = 'Demasiados intentos. Intente más tarde.';
        break;
      default:
        mensaje = e.message ?? 'Error: ${e.code}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Login'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error de conexión: $e'),
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
}
*/