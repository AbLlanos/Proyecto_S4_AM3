import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class editarCredencialesScreen extends StatefulWidget {
  const editarCredencialesScreen({super.key});

  @override
  State<editarCredencialesScreen> createState() =>
      _editarCredencialesScreenState();
}

class _editarCredencialesScreenState extends State<editarCredencialesScreen> {
  Uint8List? _perfilBytes;
  String? _perfilExt;
  Map<String, dynamic>? _userData;
  bool _cargando = true;

  static const double maxImageSizeBytes = 2 * 1024 * 1024;

  // Controladores prellenados
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _pais = TextEditingController();
  final TextEditingController _fechaNacimiento = TextEditingController();
  final TextEditingController _nuevaContrasenia = TextEditingController();
  final TextEditingController _confirmarContrasenia = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosActuales();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _pais.dispose();
    _fechaNacimiento.dispose();
    _nuevaContrasenia.dispose();
    _confirmarContrasenia.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosActuales() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('usuariosVix')
        .select('nombre, correo, telefono, pais, fechaNacimiento, perfil_url')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted && response != null) {
      setState(() {
        _userData = response;
        _nombre.text = response['nombre'] ?? '';
        _telefono.text = response['telefono'] ?? '';
        _pais.text = response['pais'] ?? '';
        _fechaNacimiento.text = response['fechaNacimiento'] ?? '';
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _pickPerfil() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null || res.files.single.bytes == null) return;

    final file = res.files.single;
    if (file.size.toDouble() > maxImageSizeBytes) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Imagen muy grande'),
            content: const Text('La imagen no puede superar los 2 MB.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _perfilBytes = file.bytes;
      _perfilExt = file.extension ?? 'jpg';
    });
  }

  Future<void> _guardarCambios() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final tel = _telefono.text.trim();
    if (tel.isNotEmpty) {
      final soloNumeros = RegExp(r'^[0-9]+$');
      if (!soloNumeros.hasMatch(tel) || tel.length != 10) {
        _showDialog(
          'Teléfono inválido',
          'Debe tener exactamente 10 dígitos numéricos.',
        );
        return;
      }
    }

    if (_nuevaContrasenia.text.isNotEmpty) {
      if (_nuevaContrasenia.text != _confirmarContrasenia.text) {
        _showDialog(
          'Contraseñas no coinciden',
          'Las contraseñas nuevas no son iguales.',
        );
        return;
      }
      if (_nuevaContrasenia.text.length < 6) {
        _showDialog(
          'Contraseña débil',
          'La contraseña debe tener al menos 6 caracteres.',
        );
        return;
      }
    }

    try {
      String? nuevaPerfilUrl;
      if (_perfilBytes != null && _perfilExt != null) {
        nuevaPerfilUrl = await _subirImagenPerfil(
          user.id,
          _perfilBytes!,
          _perfilExt!,
        );
        print('URL guardada en BD: $nuevaPerfilUrl');
      }

      final updateData = <String, dynamic>{
        'nombre': _nombre.text.trim(),
        'telefono': tel,
        'pais': _pais.text.trim(),
        'fechaNacimiento': _fechaNacimiento.text.trim(),
        if (nuevaPerfilUrl != null) 'perfil_url': nuevaPerfilUrl,
      };

      await supabase.from('usuariosVix').update(updateData).eq('id', user.id);

      // Limpiar caché de imágenes de Flutter
      PaintingBinding.instance.imageCache.clear();
      // Limpiar caché de imágenes de Flutter
      PaintingBinding.instance.imageCache.clear();

      if (_nuevaContrasenia.text.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: _nuevaContrasenia.text.trim()),
        );
      }

      if (mounted) {
        await _showDialog(
          '¡Cambios guardados!',
          'Tus datos han sido actualizados correctamente.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showDialog('Error', 'No se pudieron guardar los cambios: $e');
    }
  }

  Future<String?> _subirImagenPerfil(
    String userId,
    Uint8List imageBytes,
    String ext,
  ) async {
    try {
      final bucket = supabase.storage.from('vixDocumentaryRepository');

      // Nombre único con timestamp para romper caché
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'usuarios/$userId/perfil_$timestamp.$ext';

      // Intentar borrar archivos de perfil anteriores
      try {
        final List<FileObject> existentes = await bucket.list(
          path: 'usuarios/$userId',
        );
        final viejos = existentes
            .where((f) => f.name.startsWith('perfil_'))
            .map((f) => 'usuarios/$userId/${f.name}')
            .toList();
        if (viejos.isNotEmpty) {
          await bucket.remove(viejos);
        }
      } catch (_) {
        // Si no puede listar/borrar, continúa igual
      }

      // Subir nueva imagen
      await bucket.uploadBinary(
        path,
        imageBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final url = bucket.getPublicUrl(path);
      print('Nueva URL de perfil: $url');
      return url;
    } catch (e) {
      print('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _showDialog(String titulo, String contenido) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color.fromARGB(255, 110, 31, 93);
    const fieldColor = Color.fromARGB(197, 116, 116, 116);
    const labelColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Fondo igual al registro
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

          _cargando
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 350),
                      padding: EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        24 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Foto de perfil actual / nueva ──
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: _perfilBytes != null
                                        ? MemoryImage(_perfilBytes!)
                                        : (_userData?['perfil_url'] != null &&
                                                      _userData!['perfil_url']
                                                          .isNotEmpty
                                                  ? NetworkImage(
                                                      _userData!['perfil_url'],
                                                    )
                                                  : null)
                                              as ImageProvider?,
                                    child:
                                        (_perfilBytes == null &&
                                            (_userData?['perfil_url'] == null ||
                                                _userData!['perfil_url']
                                                    .isEmpty))
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white70,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickPerfil,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: primaryPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (_perfilBytes != null)
                              Text(
                                'Nueva imagen: ${(_perfilBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 20),

                            // ── Correo (solo lectura) ──
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Correo (no editable)',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor.withOpacity(0.5),
                                hintText:
                                    supabase.auth.currentUser?.email ?? '',
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white54),
                              controller: TextEditingController(
                                text: supabase.auth.currentUser?.email ?? '',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Nombre ──
                            TextField(
                              controller: _nombre,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Nombre',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Teléfono ──
                            TextField(
                              controller: _telefono,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                counterText: '',
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Teléfono (10 dígitos)',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── País ──
                            TextField(
                              controller: _pais,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.public,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'País',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ── Fecha de nacimiento ──
                            TextField(
                              controller: _fechaNacimiento,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Fecha de nacimiento',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Sección contraseña ──
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Cambiar contraseña (opcional)',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextField(
                              controller: _nuevaContrasenia,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Nueva contraseña',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextField(
                              controller: _confirmarContrasenia,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                labelText: 'Confirmar nueva contraseña',
                                labelStyle: const TextStyle(color: labelColor),
                                filled: true,
                                fillColor: fieldColor,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // ── Botón guardar ──
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _guardarCambios,
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Guardar cambios',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryPurple,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
