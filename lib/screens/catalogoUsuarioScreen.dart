import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:proyecto_s4_am3/screens/editarDatosVideoScreen.dart'
    hide supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class catalogoUsuarioScreen extends StatefulWidget {
  const catalogoUsuarioScreen({super.key});

  @override
  State<catalogoUsuarioScreen> createState() => _catalogoUsuarioScreenState();
}

class _catalogoUsuarioScreenState extends State<catalogoUsuarioScreen> {
  String _filtroCategoria = 'todos';
  Map<String, dynamic>? _userData;

  // ✅ Caché de Future para videos públicos SOLO
  Future<List<Map<String, dynamic>>>? _videosPublicosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _loadVideos(); // ← Una sola carga inicial
  }

  // ✅ Cargar UNA VEZ SOLO en initState
  Future<void> _loadVideos() async {
    setState(() {
      _videosPublicosFuture = leerVideosPublicos();
    });
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final user = supabase.auth.currentUser;
      print('currentUser ID: ${user?.id}');
      print('currentUser email: ${user?.email ?? "NULL"}');

      if (user == null) {
        print('No hay usuario autenticado');
        return;
      }

      // PRUEBA 1: Consulta específica con logs
      print('Buscando usuario ID: ${user.id} en usuariosVix');
      final response = await supabase
          .from('usuariosVix')
          .select('id, nombre, email, rol')
          .eq('id', user.id)
          .maybeSingle();

      print('Response TU usuario: $response');

      if (mounted) {
        setState(() {
          if (response != null) {
            _userData = response;
            print('Usuario cargado: ${_userData!['nombre']}');
          } else {
            // FALLBACK: usar datos del auth
            _userData = {
              'nombre': user.email?.split('@')[0].toUpperCase() ?? 'Usuario',
              'email': user.email ?? 'Sin email',
            };
            print('🔄 Fallback usado: ${_userData!['nombre']}');
          }
        });
      }
    } catch (e, stack) {
      print('ERROR completo: $e');
      print('Stack: $stack');
      if (mounted) {
        setState(() {
          _userData = {'nombre': 'Error', 'email': 'Revisa logs'};
        });
      }
    }
  }

  // Obtener emails de todos los autores
  Future<Map<String, String>> _getAllUserEmails(Set<String> userIds) async {
    print('Buscando NOMBRES para userIds: $userIds');
    final names = <String, String>{};

    for (String userId in userIds) {
      try {
        print('Buscando userId: $userId en usuariosVix');
        final response = await supabase
            .from('usuariosVix')
            .select('id, nombre')
            .eq('id', userId)
            .maybeSingle();

        print('Response para $userId: $response');

        if (response != null) {
          names[userId] = response['nombre'] ?? 'Sin nombre';
        } else {
          names[userId] = 'No encontrado';
        }
      } catch (e) {
        print('Error para $userId: $e');
        names[userId] = 'Usuario desconocido';
      }
    }
    print('Nombres encontrados: $names');
    return names;
  }

  // Leer videos públicos OPTIMIZADO
  Future<List<Map<String, dynamic>>> leerVideosPublicos() async {
    List<Map<String, dynamic>> videos = [];

    // ✅ SIEMPRE carga TODOS para mostrar todas las categorías
    final response = await supabase
        .from('contenidoVix')
        .select()
        .eq('es_publica', true)
        .order('fecha_subida', ascending: false)
        .limit(100); // Más videos para categorías completas

    videos = List<Map<String, dynamic>>.from(response);

    final userIds = videos.map((v) => v['user_id'].toString()).toSet();
    final emails = await _getAllUserEmails(userIds);

    for (var video in videos) {
      video['author_email'] =
          emails[video['user_id'].toString()] ?? 'Cargando...';
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo VixVideo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 31, 93),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 110, 31, 93),
                Color.fromARGB(255, 49, 24, 38),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadVideos,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _videosPublicosFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _videosPublicosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(
                      child: Text(
                        "No hay videos disponibles",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  );
                }

                final allVideos = snapshot.data!;
                return _buildCategoriasPreviews(allVideos);
              },
            ),
    );
  }

  //   ÚNICO CONTENIDO: Secciones Netflix
  Widget _buildCategoriasPreviews(List<Map<String, dynamic>> allVideos) {
    final categories = [
      'Educativo',
      'Gameplay',
      'Tutorial',
      'Entretenimiento',
      'Acción',
    ];

    // ✅ Filtrar por categoría seleccionada
    final filteredVideos = _filtroCategoria == 'todos'
        ? allVideos
        : allVideos.where((v) => v['categoria'] == _filtroCategoria).toList();

    return RefreshIndicator(
      onRefresh: _loadVideos,
      displacement: 20,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: categories.map((categoria) {
            final videosCategoria = filteredVideos
                .where((v) => v['categoria'] == categoria)
                .take(10) // Más videos por fila
                .toList();

            if (videosCategoria.isEmpty) return const SizedBox.shrink();

            return Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.amber[400], size: 28),
                      const SizedBox(width: 8),
                      Text(
                        categoria,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 280,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: videosCategoria.map((video) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => _mostrarDetalle(context, video),
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      video['portada_url'] ?? '',
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) => null,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black54,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        video['titulo'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoDetalleModal(video: video),
    );
  }
}

// VideoDetalleModal

class VideoDetalleModal extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoDetalleModal({super.key, required this.video});

  @override
  State<VideoDetalleModal> createState() => _VideoDetalleModalState();
}

class _VideoDetalleModalState extends State<VideoDetalleModal> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  Future<void> _inicializarReproductor() async {
    // Reproductor usa video_url (video directo)
    final videoUrl = widget.video['video_url'];
    print('Intentando cargar video: $videoUrl');
    if (videoUrl != null && videoUrl.isNotEmpty) {
      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _controller!.initialize();
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      } catch (e) {
        print('Error inicializando video: $e');
      }
    }
  }

  Future<void> _launchTrailer(String? trailerUrl) async {
    // trailer_url de la tabla contenidoVix
    print('Trailer URL: "$trailerUrl"');
    if (trailerUrl == null || trailerUrl.isEmpty || trailerUrl == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay enlace de trailer disponible')),
      );
      return;
    }

    final uri = Uri.parse(trailerUrl);
    print('Abriendo URI: $uri');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir el trailer')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fechaSubida = widget.video['fecha_subida'] != null
        ? DateTime.parse(widget.video['fecha_subida']).toLocal()
        : null;
    final duracion = widget.video['duracion'] ?? 'N/A';
    final edad = widget.video['edad_recomendada'] ?? 'N/A';
    final videoUrl = widget.video['video_url'];
    final trailerUrl = widget.video['trailer_url'] ?? '';
    final portadaUrl = widget.video['portada_url'] ?? '';

    print('DEBUG - trailer_url: "$trailerUrl"');

    return Container(
      // FULLSCREEN: 100% altura
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // FONDO con imagen de portada_url
      decoration: BoxDecoration(
        image: portadaUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(portadaUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              )
            : null,
        color: portadaUrl.isEmpty ? Colors.black : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            // REPRODUCTOR DE VIDEO ARRIBA (video_url)
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _isInitialized && _controller != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          IconButton(
                            iconSize: 72,
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 72,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            },
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.movie_outlined,
                        color: Colors.white70,
                        size: 72,
                      ),
              ),
            ),

            // BOTÓN TRAILER (trailer_url → YouTube)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 12,
                  ),
                  onPressed: () => _launchTrailer(trailerUrl),
                  icon: const Icon(Icons.play_arrow, size: 30),
                  label: const Text(
                    'VER TRAILER COMPLETO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // INFO COMPLETA (resto igual)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
                    Text(
                      widget.video['titulo'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 6,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          if (fechaSubida != null)
                            Text(
                              '${fechaSubida.day}/${fechaSubida.month}/${fechaSubida.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            '$duracion min • $edad+',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.video['descripcion'] ?? '',
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 28),
                        label: const Text(
                          'CERRAR',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
