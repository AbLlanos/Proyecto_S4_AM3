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

  // Caché de Future para videos públicos SOLO
  Future<List<Map<String, dynamic>>>? _videosPublicosFuture;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _videosPublicosFuture = leerVideosPublicos();
    });
  }

  // CARGAR DATOS USUARIO MEJORADO
  Future<void> _cargarDatosUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('usuariosVix')
        .select('nombre, correo')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _userData =
            response ??
            {
              'nombre': user.email?.split('@')[0].toUpperCase(),
              'email': user.email,
            };
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await supabase.auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<Map<String, String>> _getAllUserEmails(Set<String> userIds) async {
    print('Buscando NOMBRES para userIds: $userIds');
    final names = <String, String>{};

    for (String userId in userIds) {
      try {
        // Intenta usuariosVix primero
        final response = await supabase
            .from('usuariosVix')
            .select('id, nombre')
            .eq('id', userId)
            .maybeSingle();

        if (response != null && response['nombre'] != null) {
          names[userId] = response['nombre'];
          continue;
        }

        // Fallback usuarioNotas
        final responseNotas = await supabase
            .from('usuarioNotas')
            .select()
            .eq('id', userId)
            .maybeSingle();

        names[userId] = responseNotas?['nombre'] ?? 'Usuario';
      } catch (e) {
        print('Error para $userId: $e');
        names[userId] = 'Usuario';
      }
    }
    return names;
  }

  Future<List<Map<String, dynamic>>> leerVideosPublicos() async {
    List<Map<String, dynamic>> videos = [];

    final response = await supabase
        .from('contenidoVix')
        .select()
        .eq('es_publica', true)
        .order('fecha_subida', ascending: false)
        .limit(100);

    videos = List<Map<String, dynamic>>.from(response);

    final userIds = videos.map((v) => v['user_id'].toString()).toSet();
    final emails = await _getAllUserEmails(userIds);

    for (var video in videos) {
      video['author_email'] = emails[video['user_id'].toString()] ?? 'Usuario';
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            // Header del Drawer 
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[400]!, Colors.purple[800]!],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "VixScienceMov",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  //  USUARIO SEGURO
                  if (_userData != null) ...[
                    Text(
                      _userData!['nombre']?.toString() ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                  ] else ...[
                    const Text(
                      'Cargando usuario...',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Cerrar Sesión"),
                    onTap: () {
                      Navigator.pop(context);
                      _cerrarSesion();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // AppBar y resto SIN cambios (funciona perfecto)
      appBar: AppBar(
        title: const Text(
          'Catálogo VixScienceMov',
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
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

  Widget _buildCategoriasPreviews(List<Map<String, dynamic>> allVideos) {
    final categories = [
      'Tendencia',
      'Acción',
      'Miedo',
      'Aventura',
      'Clásica',
    ];
  /*
        final categories = [
      'Educativo',
      'Gameplay',
      'Tutorial',
      'Entretenimiento',
      'Acción',
    ];
*/

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
                .take(10)
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

// VideoDetalleModal (IDENTICO - funciona perfecto)
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
    final videoUrl = widget.video['video_url'];
    print('Intentando cargar video: $videoUrl');

    if (videoUrl != null && videoUrl.isNotEmpty) {
      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

        await _controller!.initialize();

        _controller!
          ..setLooping(true)
          ..setVolume(1.0);

        //..play();

        if (mounted) {
          setState(() => _isInitialized = true);
        }
      } catch (e) {
        print('Error inicializando video: $e');
      }
    }
  }

  Future<void> _launchTrailer(String? trailerUrl) async {
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
    final duracion = widget.video['duracion'] ?? 'N/A';
    final edad = widget.video['edad_recomendada'] ?? 'N/A';
    final trailerUrl = widget.video['trailer_url'];
    final portadaUrl = widget.video['portada_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // 🖼️ PORTADA
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    image: portadaUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(portadaUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[900],
                  ),
                ),

                // CONTENIDO
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🎬 TÍTULO
                      Text(
                        widget.video['titulo'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // INFO + TRAILER
                      Row(
                        children: [
                          // ▶ TRAILER PRIMERO
                          OutlinedButton.icon(
                            onPressed: () => _launchTrailer(trailerUrl),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Trailer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          _infoChip(Icons.timer, '$duracion min'),
                          const SizedBox(width: 8),
                          _infoChip(Icons.lock, '$edad+'),
                        ],
                      ),

                      Text(""),
                      //  DESCRIPCIÓN
                      Text(
                        widget.video['descripcion'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 32),

                      // 🎥 VIDEO ABAJO
                      // 🎥 VIDEO ABAJO
                      if (_isInitialized && _controller != null)
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_controller!),

                                // ▶️ BOTÓN PLAY / PAUSE
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller!.value.isPlaying
                                          ? _controller!.pause()
                                          : _controller!.play();
                                    });
                                  },
                                  child: AnimatedOpacity(
                                    opacity: _controller!.value.isPlaying
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _controller!.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.movie_outlined,
                            color: Colors.white70,
                            size: 60,
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),

            //  BOTÓN CERRAR ARRIBA IZQUIERDA
            Positioned(
              top: MediaQuery.of(context).padding.top + 50,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 22,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoChip(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
