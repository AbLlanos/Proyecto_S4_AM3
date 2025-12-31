import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:proyecto_s4_am3/screens/loginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

final supabase = Supabase.instance.client;

class registroScreen extends StatefulWidget {
  const registroScreen({super.key});

  @override
  State<registroScreen> createState() => _registroScreenState();
}

class _registroScreenState extends State<registroScreen> {
  Uint8List? _perfilBytes;
  String? _perfilExt;
  static const double maxImageSizeBytes = 2 * 1024 * 1024; // 2 MB

  Future<void> _pickPerfil() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null || res.files.single.bytes == null) return;

    final file = res.files.single;
    final size = file.size.toDouble();

    if (size > maxImageSizeBytes) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Imagen muy grande'),
            content: Text('La imagen de perfil no puede superar los 2 MB.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _perfilBytes = file.bytes;
        _perfilExt = file.extension ?? 'jpg';
      });
    }
  }

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
                child: formularioRegistro(context, _pickPerfil, _perfilBytes, _perfilExt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget formularioRegistro(
  BuildContext context,
  Future<void> Function() pickPerfil,
  Uint8List? perfilBytes,
  String? perfilExt,
) {
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

        // IMAGEN DE PERFIL
        const Text(
          'Imagen de perfil (JPG/PNG, máx 2 MB)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: pickPerfil,
            icon: const Icon(Icons.person_add, size: 28),
            label: Text(
              perfilBytes != null
                  ? 'Imagen seleccionada (${(perfilBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB)'
                  : 'Seleccionar imagen de perfil',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // CAMPOS DE TEXTO
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

        TextField(
          controller: telefono,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: const Icon(Icons.phone, color: Colors.white70),
            border: const OutlineInputBorder(),
            labelText: "Teléfono (10 dígitos)",
            labelStyle: TextStyle(color: labelColor),
            filled: true,
            fillColor: fieldColor,
          ),
        ),
        const SizedBox(height: 12),

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

        // BOTÓN CORREGIDO 
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => registroVixUsuarioSupabase(
              nombre,
              correo,
              telefono,
              pais,
              fechaNacimiento,
              contrasenia,
              context,
              perfilBytes,
              perfilExt,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 110, 31, 93),
            ),
            child: const Text(
              'Registrarse',
              style: TextStyle(color: Colors.white),
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

// FUNCIÓN PRINCIPAL CORREGIDA
Future<void> registroVixUsuarioSupabase(
  TextEditingController nombre,
  TextEditingController correo,
  TextEditingController telefono,
  TextEditingController pais,
  TextEditingController fechaNacimiento,
  TextEditingController contrasenia,
  BuildContext context,
  Uint8List? perfilBytes,
  String? perfilExt, // ← nullable
) async {
  // Validaciones (iguales)
  if (correo.text.isEmpty ||
      contrasenia.text.isEmpty ||
      nombre.text.isEmpty ||
      telefono.text.isEmpty ||
      pais.text.isEmpty ||
      fechaNacimiento.text.isEmpty) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Por favor complete todos los campos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return;
  }

  final tel = telefono.text.trim();
  final soloNumeros = RegExp(r'^[0-9]+$');
  if (!soloNumeros.hasMatch(tel) || tel.length != 10) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Teléfono inválido'),
          content: const Text('El número de teléfono debe tener exactamente 10 dígitos numéricos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return;
  }

  try {
    final AuthResponse res = await supabase.auth.signUp(
      email: correo.text.trim(),
      password: contrasenia.text.trim(),
      data: {
        'nombre': nombre.text.trim(),
        'telefono': tel,
        'pais': pais.text.trim(),
        'fechaNacimiento': fechaNacimiento.text.trim(),
      },
    );

    final user = res.user;
    if (user == null) {
      throw Exception('No se pudo crear el usuario');
    }

    // SUBIR IMAGEN (SOLO SI AMBOS EXISTEN)
    String? perfilUrl;
    if (perfilBytes != null && perfilExt != null) {
      print('Subiendo imagen ${perfilBytes.lengthInBytes} bytes');
      perfilUrl = await _subirImagenPerfil(user.id, perfilBytes, perfilExt);
      print(' URL: $perfilUrl');
    } else {
      print('Sin imagen de perfil');
    }

    await guardarUsuarioEnSupabase(
      user.id,
      nombre.text.trim(),
      correo.text.trim(),
      tel,
      pais.text.trim(),
      fechaNacimiento.text.trim(),
      perfilUrl,
    );

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(' Registro exitoso'),
          content: const Text(
            'Tu cuenta se ha creado correctamente.\nAhora puedes iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.pushNamed(context, '/login');
    }
  } on AuthException catch (e) {
    if (context.mounted) {
      final msg = e.message.toLowerCase();
      String mensaje = e.message;

      if (msg.contains('user already registered') || msg.contains('already exists')) {
        mensaje = 'Ya existe una cuenta con este correo.';
      } else if (msg.contains('password') && msg.contains('weak')) {
        mensaje = 'La contraseña es muy débil.';
      } else if (msg.contains('email') && msg.contains('invalid')) {
        mensaje = 'Correo electrónico inválido.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de Registro'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// FUNCIÓN DE SUBIDA FINAL
Future<String?> _subirImagenPerfil(String userId, Uint8List imageBytes, String ext) async {
  try {
    final bucket = supabase.storage.from('vixDocumentaryRepository');
    final path = 'usuarios/$userId/perfil.$ext';
    
    print('Subiendo a: $path');
    
    await bucket.uploadBinary(
      path,
      imageBytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    
    final url = bucket.getPublicUrl(path);
    print(' Subida exitosa: $url');
    return url;
  } catch (e) {
    print('Error subiendo imagen: $e');
    return null;
  }
}

Future<void> guardarUsuarioEnSupabase(
  String uid,
  String nombre,
  String correo,
  String telefono,
  String pais,
  String fechaNacimiento,
  String? perfilUrl,
) async {
  await supabase.from('usuariosVix').insert({
    'id': uid,
    'nombre': nombre,
    'correo': correo,
    'telefono': telefono,
    'pais': pais,
    'fechaNacimiento': fechaNacimiento,
    'perfil_url': perfilUrl,
    'rol': 'usuario',
  });
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
