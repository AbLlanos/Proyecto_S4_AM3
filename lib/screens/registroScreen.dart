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
  static const double maxImageSizeBytes = 2 * 1024 * 1024;

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
            title: const Text('Imagen muy grande'),
            content: const Text(
              'La imagen de perfil no puede superar los 2 MB.',
            ),
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
                // ← Ahora usa el StatefulWidget del formulario
                child: FormularioRegistro(
                  pickPerfil: _pickPerfil,
                  perfilBytes: _perfilBytes,
                  perfilExt: _perfilExt,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FORMULARIO COMO StatefulWidget
// ─────────────────────────────────────────────
class FormularioRegistro extends StatefulWidget {
  final Future<void> Function() pickPerfil;
  final Uint8List? perfilBytes;
  final String? perfilExt;

  const FormularioRegistro({
    super.key,
    required this.pickPerfil,
    required this.perfilBytes,
    required this.perfilExt,
  });

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  final TextEditingController fechaNacimiento = TextEditingController();

  // ── NUEVO: estado para el dropdown de país ──
  String? _paisSeleccionado;

  static const List<String> _paises = [
    'Argentina',
    'Bolivia',
    'Brasil',
    'Canadá',
    'Chile',
    'Colombia',
    'Costa Rica',
    'Cuba',
    'Ecuador',
    'El Salvador',
    'España',
    'Estados Unidos',
    'Francia',
    'Guatemala',
    'Honduras',
    'Italia',
    'Jamaica',
    'México',
    'Nicaragua',
    'Panamá',
    'Paraguay',
    'Perú',
    'Portugal',
    'Puerto Rico',
    'República Dominicana',
    'Uruguay',
    'Venezuela',
    'Alemania',
    'Japón',
    'China',
  ];

  // ── NUEVO: date picker que guarda como texto ──
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      // ✅ Sin locale — evita el crash
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 110, 31, 93),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final texto =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        fechaNacimiento.text = texto;
      });
    }
  }

  @override
  void dispose() {
    nombre.dispose();
    correo.dispose();
    telefono.dispose();
    contrasenia.dispose();
    fechaNacimiento.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: widget.pickPerfil,
              icon: const Icon(Icons.person_add, size: 28),
              label: Text(
                widget.perfilBytes != null
                    ? 'Imagen seleccionada (${(widget.perfilBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB)'
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

          // NOMBRE
          TextField(
            controller: nombre,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
              border: const OutlineInputBorder(),
              labelText: "Nombre",
              labelStyle: const TextStyle(color: labelColor),
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
              border: const OutlineInputBorder(),
              labelText: "Correo electrónico",
              labelStyle: const TextStyle(color: labelColor),
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
              border: const OutlineInputBorder(),
              labelText: "Contraseña",
              labelStyle: const TextStyle(color: labelColor),
              filled: true,
              fillColor: fieldColor,
            ),
          ),
          const SizedBox(height: 12),

          // TELÉFONO
          TextField(
            controller: telefono,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              counterText: '',
              prefixIcon: const Icon(Icons.phone, color: Colors.white70),
              border: const OutlineInputBorder(),
              labelText: "Teléfono (10 dígitos)",
              labelStyle: const TextStyle(color: labelColor),
              filled: true,
              fillColor: fieldColor,
            ),
          ),
          const SizedBox(height: 12),

          // ── NUEVO: DROPDOWN DE PAÍS ──
          DropdownButtonFormField<String>(
            value: _paisSeleccionado,
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.public, color: Colors.white70),
              border: const OutlineInputBorder(),
              labelText: "País",
              labelStyle: const TextStyle(color: labelColor),
              filled: true,
              fillColor: fieldColor,
            ),
            hint: const Text(
              "Selecciona tu país",
              style: TextStyle(color: Colors.white54),
            ),
            items: _paises.map((pais) {
              return DropdownMenuItem<String>(
                value: pais,
                child: Text(pais, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _paisSeleccionado = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // ── NUEVO: FECHA CON DATE PICKER ──
          TextField(
            controller: fechaNacimiento,
            readOnly: true, // evita teclado manual
            onTap: _seleccionarFecha,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.calendar_today,
                color: Colors.white70,
              ),
              border: const OutlineInputBorder(),
              labelText: "Fecha de nacimiento",
              labelStyle: const TextStyle(color: labelColor),
              filled: true,
              fillColor: fieldColor,
              hintText: "Toca para seleccionar",
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÓN REGISTRARSE
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Crea un controller temporal para pais con el valor del dropdown
                final paisController = TextEditingController(
                  text: _paisSeleccionado ?? '',
                );
                registroVixUsuarioSupabase(
                  nombre,
                  correo,
                  telefono,
                  paisController,
                  fechaNacimiento,
                  contrasenia,
                  context,
                  widget.perfilBytes,
                  widget.perfilExt,
                );
              },
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
          content: const Text(
            'El número de teléfono debe tener exactamente 10 dígitos numéricos.',
          ),
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

      String mensaje = switch (true) {
        _
            when msg.contains('user already registered') ||
                msg.contains('already exists') =>
          'Ya existe una cuenta con este correo.',
        _ when msg.contains('weak') =>
          'La contraseña es muy débil (mínimo 6 caracteres).',
        _ when msg.contains('at least 6') =>
          'La contraseña debe tener al menos 6 caracteres.',
        _ when msg.contains('should be at least') =>
          'La contraseña debe tener al menos 6 caracteres.',
        _ when msg.contains('password') =>
          'La contraseña es muy débil (mínimo 6 caracteres).',
        _ when msg.contains('invalid') && msg.contains('email') =>
          'Correo electrónico inválido.',
        _ when msg.contains('unable to validate') =>
          'Correo electrónico inválido.',
        _ => e.message,
      };

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
Future<String?> _subirImagenPerfil(
  String userId,
  Uint8List imageBytes,
  String ext,
) async {
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
