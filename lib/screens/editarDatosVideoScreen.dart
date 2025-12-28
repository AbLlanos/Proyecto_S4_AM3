import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Editardatosvideoscreen extends StatefulWidget {
  const Editardatosvideoscreen({super.key});

  @override
  State<Editardatosvideoscreen> createState() => _EditardatosvideoscreenState();
}

class _EditardatosvideoscreenState extends State<Editardatosvideoscreen> {
  Uint8List? _portadaBytes;
  String? _portadaExt;
  Map<String, dynamic>? videoData;

  final TextEditingController titulo = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController duracion = TextEditingController();
  final TextEditingController edadRecomendada = TextEditingController();

  bool _esPublica = true;
  static const double maxImageSizeBytes = 1 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    // ← OBTENER DATOS de pushNamed arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      print('Editardatosvideoscreen initState INICIADO');
      print('videoData from arguments: $videoData');

      if (videoData != null) {
        print('CARGANDO DATOS:');
        print('  titulo: ${videoData!['titulo']}');
        print('  descripcion: ${videoData!['descripcion']}');
        print('  duracion: ${videoData!['duracion']}');
        print('  edad_recomendada: ${videoData!['edad_recomendada']}');
        print('  es_publica: ${videoData!['es_publica']}');

        titulo.text = videoData!['titulo'] ?? '';
        descripcion.text = videoData!['descripcion'] ?? '';
        duracion.text = videoData!['duracion']?.toString() ?? '';
        edadRecomendada.text = videoData!['edad_recomendada']?.toString() ?? '';
        _esPublica =
            videoData!['es_publica'] == true ||
            videoData!['es_publica'] == 'true';

        print('DATOS CARGADOS CORRECTAMENTE');
        setState(() {});
      } else {
        print('ERROR: videoData es NULL');
      }
    });
  }

  Future<void> _pickPortada() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null || res.files.single.bytes == null) return;

    final file = res.files.single;
    final size = file.size.toDouble();

    if (size > maxImageSizeBytes) {
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Imagen muy grande'),
          content: Text('La portada no puede superar 1 MB.'),
        ),
      );
      return;
    }

    setState(() {
      _portadaBytes = file.bytes;
      _portadaExt = file.extension ?? 'jpg';
    });
  }

  Future<void> actualizarVideo() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Error'),
            content: Text('Debes iniciar sesión.'),
          ),
        );
      }
      return;
    }

    if (titulo.text.trim().isEmpty || descripcion.text.trim().isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Datos incompletos'),
            content: Text('Completa título y descripción.'),
          ),
        );
      }
      return;
    }

    if (videoData == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Error', style: TextStyle(color: Colors.white)),
            content: const Text(
              'No hay video para actualizar.\nRegresa y selecciona un video.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
        );
      }
      return;
    }

    try {
      Map<String, dynamic> updateData = {
        'titulo': titulo.text.trim(),
        'descripcion': descripcion.text.trim(),
        'duracion': duracion.text.trim(),
        'edad_recomendada': edadRecomendada.text.trim(),
        'es_publica': _esPublica,
      };

      if (_portadaBytes != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        final bucket = supabase.storage.from('vixDocumentaryRepository');
        final portadaPath =
            '${user.id}/portadas/$tempId/portada.${_portadaExt ?? "jpg"}';

        await bucket.uploadBinary(
          portadaPath,
          _portadaBytes!,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        updateData['portada_url'] = bucket.getPublicUrl(portadaPath);
      }

      print('💾 Actualizando ID: ${videoData!['id']}');
      await supabase
          .from('contenidoVix')
          .update(updateData)
          .eq('id', videoData!['id']);

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('¡Éxito!'),
              ],
            ),
            content: const Text(
              'Video actualizado correctamente',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: Text(
              'Error al actualizar:\n$e',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Editardatosvideoscreen BUILD INICIADO');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Video"),
        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
      ),
      body: Container(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Editar datos del video",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Portada
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickPortada,
                    icon: const Icon(Icons.image, size: 24),
                    label: Text(
                      _portadaBytes == null
                          ? 'Cambiar portada'
                          : 'Nueva portada ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                TextField(
                  controller: titulo,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Título",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(197, 116, 116, 116),
                  ),
                ),
                const SizedBox(height: 12),

                // Descripción
                TextField(
                  controller: descripcion,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(197, 116, 116, 116),
                  ),
                ),
                const SizedBox(height: 12),

                // Duración
                TextField(
                  controller: duracion,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Duración (min)",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(197, 116, 116, 116),
                  ),
                ),
                const SizedBox(height: 12),

                // Edad
                TextField(
                  controller: edadRecomendada,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Edad recomendada",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(197, 116, 116, 116),
                  ),
                ),
                const SizedBox(height: 12),

                // Visibilidad
                Row(
                  children: [
                    const Text(
                      'Visibilidad: ',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    DropdownButton<bool>(
                      value: _esPublica,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey[800],
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Pública')),
                        DropdownMenuItem(value: false, child: Text('Privada')),
                      ],
                      onChanged: (val) =>
                          setState(() => _esPublica = val ?? true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: actualizarVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 110, 31, 93),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Actualizar Video',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
