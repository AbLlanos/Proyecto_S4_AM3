import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/screens/loginScreen.dart';

class registroScreen extends StatelessWidget {
  const registroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color.fromARGB(255, 110, 31, 93);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://ekosnegocios.com/image/posts/December2024/xZOv1p7aKZpYIXbSDtTi.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: const Color(0xAA000000)),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                padding: const EdgeInsets.all(24),
                child: formularioRegistro(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void irPantallaLogin(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => loginScreen()),
  );
}

void irPantallaLoginRegistrado(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => loginScreen()),
  );
}

//Funcion de registro

Widget formularioRegistro(context) {
  TextEditingController nombre = TextEditingController();
  TextEditingController apellido = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController telefono = TextEditingController();
  TextEditingController contrasenia = TextEditingController();
  TextEditingController pais = TextEditingController();
  TextEditingController fechaNacimiento = TextEditingController();

  const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
  const Color labelColor = Colors.white;

  return Column(
    children: [
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
        controller: nombre,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese el nombre",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      Text(""),

      TextField(
        controller: apellido,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese el apellido",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      Text(""),

      TextField(
        controller: correo,
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
        controller: contrasenia,
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
      Text(""),

      TextField(
        controller: telefono,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.phone, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese el telefono",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      Text(""),

      TextField(
        controller: pais,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.public, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese el pais",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      Text(""),

      TextField(
        controller: fechaNacimiento,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          border: OutlineInputBorder(),
          labelText: "Ingrese la fecha de nacimiento",
          labelStyle: TextStyle(color: labelColor),
          filled: true,
          fillColor: fieldColor,
        ),
      ),
      Text(""),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => RegistroVixUsuario(correo, contrasenia, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              110,
              31,
              93,
            ),
          ),
          child: const Text('Registrarse', style: TextStyle(color: labelColor),),
        ),
      ),

      Text(""),

      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ya tienes una cuenta?",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => irPantallaLoginRegistrado(context),
              child: const Text(
                "Iniciar sesión",
                style: TextStyle(color: Color.fromARGB(255, 167, 45, 158)),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


Future<void> RegistroVixUsuario(correo, contrasenia, context) async {
  if (correo.text.isEmpty || contrasenia.text.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
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
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: correo.text.trim(),
          password: contrasenia.text.trim(),
        );

    Navigator.pushNamed(context, '/login');
  } on FirebaseAuthException catch (e) {
    String mensaje = 'Error desconocido';
    switch (e.code) {
      case 'weak-password':
        mensaje = 'La contraseña es muy débil. Use al menos 6 caracteres.';
        break;
      case 'email-already-in-use':
        mensaje = 'El correo ya está registrado.';
        break;
      case 'invalid-email':
        mensaje = 'Correo electrónico inválido.';
        break;
      default:
        mensaje = e.message ?? 'Error: ${e.code}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Registro'),
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
