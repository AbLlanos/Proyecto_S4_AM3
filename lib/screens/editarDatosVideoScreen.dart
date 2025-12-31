import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Editardatosvideoscreen extends StatefulWidget {
  const Editardatosvideoscreen({super.key});

  @override
  State<Editardatosvideoscreen> createState() => _EditardatosvideoscreenState();
}

class _EditardatosvideoscreenState extends State<Editardatosvideoscreen> {
  Map<String, dynamic>? videoData;

  final TextEditingController titulo = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController duracion = TextEditingController();
  final TextEditingController edadRecomendada = TextEditingController();
  final TextEditingController trailerUrl = TextEditingController();
  final TextEditingController portadaUrl = TextEditingController();
  final TextEditingController videoUrl = TextEditingController();

  String _categoriaSeleccionada = 'Tendencia';
  bool _esPublica = true;

  // Misma conversión que al agregar (solo para video Dropbox)
  String _convertirDropboxUrl(String url) {
    return url.replaceAll('dl=0', 'raw=1');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (videoData != null) {
        titulo.text = videoData!['titulo'] ?? '';
        descripcion.text = videoData!['descripcion'] ?? '';
        duracion.text = videoData!['duracion']?.toString() ?? '';
        edadRecomendada.text =
            videoData!['edad_recomendada']?.toString() ?? '';
        trailerUrl.text = videoData!['trailer_url'] ?? '';
        portadaUrl.text = videoData!['portada_url'] ?? '';
        videoUrl.text = videoData!['video_url'] ?? '';
        _esPublica =
            videoData!['es_publica'] == true || videoData!['es_publica'] == 'true';
        _categoriaSeleccionada = videoData!['categoria'] ?? 'Tendencia';

        setState(() {});
      } else {
        // Si quieres, aquí puedes mostrar un diálogo de error
        debugPrint('ERROR: videoData es NULL');
      }
    });
  }

  Future<void> actualizarVideo() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Error'),
          content: Text('Debes iniciar sesión.'),
        ),
      );
      return;
    }

    if (titulo.text.trim().isEmpty ||
        descripcion.text.trim().isEmpty ||
        duracion.text.trim().isEmpty ||
        edadRecomendada.text.trim().isEmpty ||
        trailerUrl.text.trim().isEmpty ||
        portadaUrl.text.trim().isEmpty ||
        videoUrl.text.trim().isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Datos incompletos'),
          content: Text('Debe completar todos los campos.'),
        ),
      );
      return;
    }

    if (videoData == null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'No hay video para actualizar.\nRegresa y selecciona un video.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final portadaUrlFinal = portadaUrl.text.trim();
      final videoUrlFinal = _convertirDropboxUrl(videoUrl.text.trim());

      final updateData = {
        'titulo': titulo.text.trim(),
        'descripcion': descripcion.text.trim(),
        'duracion': duracion.text.trim(),
        'edad_recomendada': edadRecomendada.text.trim(),
        'trailer_url': trailerUrl.text.trim(),
        'portada_url': portadaUrlFinal,
        'video_url': videoUrlFinal,
        'es_publica': _esPublica,
        'categoria': _categoriaSeleccionada,
      };

      await supabase
          .from('contenidoVix')
          .update(updateData)
          .eq('id', videoData!['id']);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Éxito!'),
          content: const Text('Video actualizado correctamente'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al actualizar: $e'),
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

  @override
  Widget build(BuildContext context) {
    const Color fieldColor = Color.fromARGB(197, 116, 116, 116);
    const Color labelColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar película',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
        elevation: 0,
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Editar datos de la película",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),   
                const SizedBox(height: 24),

                // PORTADA URL
                const Text(
                  'URL de la portada',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: portadaUrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.image, color: Colors.white70),
                    suffixIcon: portadaUrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              portadaUrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    labelText: "URL portada",
                    labelStyle: const TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                    hintText: "https://image.tmdb.org/...jpg",
                  ),
                ),
                const SizedBox(height: 16),

                // VIDEO URL
                const Text(
                  'URL del video (Dropbox)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: videoUrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.movie, color: Colors.white70),
                    suffixIcon: videoUrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              videoUrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    labelText: "URL video Dropbox",
                    labelStyle: const TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                    hintText: "https://www.dropbox.com/...dl=0",
                  ),
                ),
                const SizedBox(height: 16),

                // TRAILER URL
                const Text(
                  'URL del trailer (YouTube)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: trailerUrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.link, color: Colors.white70),
                    suffixIcon: trailerUrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              trailerUrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    labelText: "URL trailer YouTube",
                    labelStyle: const TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fieldColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                TextField(
                  controller: titulo,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.movie, color: Colors.white70),
                    border: OutlineInputBorder(),
                    labelText: "Título",
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
                    prefixIcon:
                        Icon(Icons.description, color: Colors.white70),
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
                    prefixIcon: Icon(Icons.confirmation_number,
                        color: Colors.white70),
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
                          child: Text('Pública',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Privada',
                              style: TextStyle(color: Colors.white)),
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
                            value: 'Tendencia', child: Text('Tendencia')),
                        DropdownMenuItem(
                            value: 'Acción', child: Text('Acción')),
                        DropdownMenuItem(
                            value: 'Miedo', child: Text('Miedo')),
                        DropdownMenuItem(
                            value: 'Aventura', child: Text('Aventura')),
                        DropdownMenuItem(
                            value: 'Clásica', child: Text('Clásica')),
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

                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: actualizarVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 110, 31, 93),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Actualizar película',
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
