import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/screens/loginScreen.dart';
import 'package:firebase_database/firebase_database.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 5),
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
  TextEditingController correo = TextEditingController();
  TextEditingController telefono = TextEditingController();
  TextEditingController contrasenia = TextEditingController();
  TextEditingController pais = TextEditingController();
  TextEditingController fechaNacimiento = TextEditingController();

  const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
  const Color labelColor = Colors.white;

  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: Text(
              "Debe llenar los siguientes espacios obligatoriamente",
              style: TextStyle(fontSize: 18, color: Colors.amber[50]),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // NOMBRE
        TextField(
          controller: nombre,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "Nombre",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

        // CORREO
        TextField(
          controller: correo,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "Correo electrónico",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

        // CONTRASEÑA
        TextField(
          controller: contrasenia,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "Contraseña",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

        // TELÉFONO
        TextField(
          controller: telefono,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "Teléfono",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

        // PAÍS
        TextField(
          controller: pais,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.public, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "País",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

        // FECHA
        TextField(
          controller: fechaNacimiento,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
            border: OutlineInputBorder(),
            labelText: "Fecha de nacimiento",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 24),

        // BOTÓN
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => RegistroVixUsuario(
              nombre,
              correo,
              telefono,
              pais,
              fechaNacimiento,
              contrasenia,
              context,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 110, 31, 93),
            ),
            child: const Text(
              'Registrarse',
              style: TextStyle(color: labelColor),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // LINK LOGIN
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ya tienes una cuenta? ",
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
        const SizedBox(height: 20),
      ],
    ),
  );
}

Future<void> RegistroVixUsuario(
  nombre,
  correo,
  telefono,
  pais,
  fechaNacimiento,
  contrasenia,
  context,
) async {
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

    // GUARDAR DATOS DEL USUARIO en Firebase usando UID
    await guardarUsuarioEnFirebase(
      credential.user!.uid,
      nombre.text.trim(),
      correo.text.trim(),
      telefono.text.trim(),
      pais.text.trim(),
      fechaNacimiento.text.trim(),
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

// Función para guardar datos del usuario en Firebase
Future<void> guardarUsuarioEnFirebase(
  String uid,
  String nombre,
  String correo,
  String telefono,
  String pais,
  String fechaNacimiento,
) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("usuarios/$uid");

  await ref.set({
    "nombre": nombre,
    "correo": correo,
    "telefono": telefono,
    "pais": pais,
    "fechaNacimiento": fechaNacimiento,
  });
}
