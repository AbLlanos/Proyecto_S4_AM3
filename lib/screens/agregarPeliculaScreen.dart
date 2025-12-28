import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Agregarpeliculascreen extends StatefulWidget {
  const Agregarpeliculascreen({super.key});

  @override
  State<Agregarpeliculascreen> createState() => _AgregarpeliculascreenState();
}

class _AgregarpeliculascreenState extends State<Agregarpeliculascreen> {
  Uint8List? _videoBytes;
  Uint8List? _portadaBytes;
  String? _videoExt;
  String? _portadaExt;

  final TextEditingController titulo = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController duracion = TextEditingController();
  final TextEditingController edadRecomendada = TextEditingController();

  String? _categoriaSeleccionada = 'Educativo';

  bool _esPublica = true; // pública/privada
  static const double maxVideoSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const double maxImageSizeBytes = 1 * 1024 * 1024; // 1 MB

  Future<void> _pickVideo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (res == null || res.files.single.bytes == null) return;

    final file = res.files.single;
    final size = file.size.toDouble();

    if (size > maxVideoSizeBytes) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Archivo muy grande'),
          content: Text('El video no puede superar los 5 MB.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _videoBytes = file.bytes;
      _videoExt = file.extension ?? 'mp4';
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
        builder: (context) => AlertDialog(
          title: Text('Imagen muy grande'),
          content: Text('La portada no puede superar 1 MB.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _portadaBytes = file.bytes;
      _portadaExt = file.extension ?? 'jpg';
    });
  }

  Future<void> guardarPelicula() async {
    print('INICIANDO SUBIDA DE VIDEO...');

    final user = supabase.auth.currentUser;
    print('Usuario: ${user?.email ?? "NULL (no autenticado)"}');

    if (user == null) {
      print('ERROR: Usuario no autenticado');
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Error'),
          content: Text('Debes iniciar sesión para agregar videos.'),
        ),
      );
      return;
    }

    print(
      'Video bytes: ${_videoBytes != null ? "${(_videoBytes!.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB" : "NULL"}',
    );
    print(
      'Portada bytes: ${_portadaBytes != null ? "${(_portadaBytes!.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB" : "NULL"}',
    );

    if (_videoBytes == null) {
      print('ERROR: No hay video seleccionado');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Falta video'),
          content: Text('Selecciona el video antes de guardar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_portadaBytes == null) {
      print('ERROR: No hay portada seleccionada');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Falta portada'),
          content: Text('Selecciona una imagen para la portada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (titulo.text.trim().isEmpty ||
        descripcion.text.trim().isEmpty ||
        duracion.text.trim().isEmpty ||
        edadRecomendada.text.trim().isEmpty) {
      print('ERROR: Título o descripción vacíos');
      print('Título: "${titulo.text.trim()}"');
      print('Descripción: "${descripcion.text.trim()}"');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Datos incompletos'),
          content: Text('Debe completar toda la información solicitada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      print('Generando ID temporal...');
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      print('tempId: $tempId');

      final bucket = supabase.storage.from('vixDocumentaryRepository');
      print('Bucket: vixDocumentaryRepository');

      // Subir video
      final videoPath =
          '${user.id}/videos/$tempId/pelicula.${_videoExt ?? "mp4"}';
      print('Subiendo VIDEO a: $videoPath');
      await bucket.uploadBinary(
        videoPath,
        _videoBytes!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      print('VIDEO subido exitosamente');

      // Subir portada
      final portadaPath =
          '${user.id}/portadas/$tempId/portada.${_portadaExt ?? "jpg"}';
      print('Subiendo PORTADA a: $portadaPath');
      await bucket.uploadBinary(
        portadaPath,
        _portadaBytes!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      print('PORTADA subida exitosamente');

      final videoUrl = bucket.getPublicUrl(videoPath);
      final portadaUrl = bucket.getPublicUrl(portadaPath);
      print('videoUrl: $videoUrl');
      print('portadaUrl: $portadaUrl');

      final ahora = DateTime.now();
      print('fecha_subida: ${ahora.toIso8601String()}');

      print('Insertando en tabla contenidoVix...');
      await supabase.from('contenidoVix').insert({
        'user_id': user.id,
        'portada_url': portadaUrl,
        'titulo': titulo.text.trim(),
        'descripcion': descripcion.text.trim(),
        'duracion': duracion.text.trim(),
        'edad_recomendada': edadRecomendada.text.trim(),
        'fecha_subida': ahora.toIso8601String(),
        'video_url': videoUrl,
        'es_publica': _esPublica,
        'categoria': _categoriaSeleccionada,
      });
      print('INSERT en BD exitoso');

      print('TODO EXITOSO - Mostrando diálogo de éxito');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Éxito'),
          content: Text('Video agregado correctamente'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e, stackTrace) {
      print('ERROR COMPLETO:');
      print('Tipo: ${e.runtimeType}');
      print('Mensaje: $e');
      print('StackTrace: $stackTrace');
      print('user.id: ${user?.id}');

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al guardar: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    print('FIN DE guardarPelicula()');
  }

  //Cuerpo del formulario
  @override
  Widget build(BuildContext context) {
    const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
    const Color labelColor = Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text("Añadir video")),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://img.freepik.com/foto-gratis/luces-brillantes-negro_23-2147785758.jpg?semt=ais_hybrid&w=740&q=80',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "Agregar video",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "Selecciona portada, video y completa los datos",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(226, 226, 226, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // Label
                const Text(
                  'Selecciona una imagen para la portada (JPG/PNG, máx 1 MB)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Seleccionar PORTADA (imagen) - ocupa todo el ancho
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickPortada,
                    icon: const Icon(Icons.image, size: 28),
                    label: Text(
                      _portadaBytes == null
                          ? 'Seleccionar portada (<= 1 MB)'
                          : 'Portada seleccionada ✓',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Título
                TextField(
                  controller: titulo,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.movie, color: Colors.white70),
                    border: OutlineInputBorder(),
                    labelText: "Título del video",
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Descripción
                TextField(
                  controller: descripcion,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description, color: Colors.white70),
                    border: OutlineInputBorder(),
                    labelText: "Descripción",
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Duración
                TextField(
                  controller: duracion,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.timer, color: Colors.white70),
                    border: OutlineInputBorder(),
                    labelText: "Duración (minutos)",
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Edad recomendada
                TextField(
                  controller: edadRecomendada,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.confirmation_number,
                      color: Colors.white70,
                    ),
                    border: OutlineInputBorder(),
                    labelText: "Edad recomendada",
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Visibilidad
                Row(
                  children: [
                    const Text(
                      'Visibilidad:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<bool>(
                      value: _esPublica,
                      dropdownColor: Colors.black87,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text(
                            'Pública',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text(
                            'Privada',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _esPublica = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categoría
                Row(
                  children: [
                    const Text(
                      'Categoría:',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _categoriaSeleccionada,
                      dropdownColor: Colors.black87,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'Educativo',
                          child: Text('Educativo'),
                        ),
                        DropdownMenuItem(
                          value: 'Gameplay',
                          child: Text('Gameplay'),
                        ),
                        DropdownMenuItem(
                          value: 'Tutorial',
                          child: Text('Tutorial'),
                        ),
                        DropdownMenuItem(
                          value: 'Entretenimiento',
                          child: Text('Entretenimiento'),
                        ),
                        DropdownMenuItem(
                          value: 'Acción',
                          child: Text('Acción'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _categoriaSeleccionada = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Label explicativo para VIDEO
                const Text(
                  'Selecciona el video (MP4, máx 5 MB)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Seleccionar VIDEO - ocupa todo el ancho
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.movie, size: 28),
                    label: Text(
                      _videoBytes == null
                          ? 'Seleccionar video (<= 5 MB)'
                          : 'Video seleccionado ✓',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: guardarPelicula,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 110, 31, 93),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Agregar Video',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
