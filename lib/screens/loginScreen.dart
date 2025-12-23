import 'package:firebase_auth/firebase_auth.dart';
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
        // Fondo con imagen CORREGIDO
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
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
    children: [

      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: const Text(
            "Vix Documentary",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              "Debe llenar los siguientes espacios obligatoriamente",
              style: TextStyle(fontSize: 20, color: Colors.amber[50]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      Text(""),

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
      Text(""),

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
          onPressed: () =>
              loginVixUsuario(correoUsuario, contraseniaUsuario, context),
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

    Navigator.pushNamed(context, '/catalogo');
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
