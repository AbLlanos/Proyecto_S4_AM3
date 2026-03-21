import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:proyecto_s4_am3/screens/editarDatosVideoScreen.dart'
    hide supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:proyecto_s4_am3/screens/editarCredencialesScreen.dart';

class catalogoUsuarioScreen extends StatefulWidget {
  const catalogoUsuarioScreen({super.key});

  @override
  State<catalogoUsuarioScreen> createState() => _catalogoUsuarioScreenState();
}

class _catalogoUsuarioScreenState extends State<catalogoUsuarioScreen> {
  String _filtroCategoria = 'todos';
  Map<String, dynamic>? _userData;
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

  Future<void> _cargarDatosUsuario() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('usuariosVix')
        .select('nombre, correo, perfil_url')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        if (response != null) {
          // Agrega timestamp para romper caché de imagen
          final rawUrl = response['perfil_url'];
          _userData = {
            ...response,
            'perfil_url': rawUrl != null && rawUrl.isNotEmpty
                ? '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}'
                : null,
          };
        } else {
          _userData = {
            'nombre': user.email?.split('@')[0].toUpperCase(),
            'correo': user.email,
            'perfil_url': null,
          };
        }
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
    final names = <String, String>{};
    for (String userId in userIds) {
      try {
        final response = await supabase
            .from('usuariosVix')
            .select('id, nombre')
            .eq('id', userId)
            .maybeSingle();

        if (response != null && response['nombre'] != null) {
          names[userId] = response['nombre'];
          continue;
        }

        final responseNotas = await supabase
            .from('usuarioNotas')
            .select()
            .eq('id', userId)
            .maybeSingle();

        names[userId] = responseNotas?['nombre'] ?? 'Usuario';
      } catch (e) {
        names[userId] = 'Usuario';
      }
    }
    return names;
  }

  Future<List<Map<String, dynamic>>> leerVideosPublicos() async {
    List<Map<String, dynamic>> videos = [];

    if (_filtroCategoria == 'todos') {
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('es_publica', true)
          .order('fecha_subida', ascending: false)
          .limit(100);
      videos = List<Map<String, dynamic>>.from(response);
    } else {
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('es_publica', true)
          .eq('categoria', _filtroCategoria)
          .order('fecha_subida', ascending: false)
          .limit(100);
      videos = List<Map<String, dynamic>>.from(response);
    }

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
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: _userData != null
                  ? Text(
                      _userData!['nombre']?.toString() ?? 'Usuario',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    )
                  : const Text(
                      'Cargando...',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
              accountEmail: _userData != null
                  ? Text(
                      _userData!['correo']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    )
                  : null,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple[400]!, Colors.purple[800]!],
                ),
              ),
              currentAccountPicture: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      _userData?['perfil_url'] != null &&
                          _userData!['perfil_url'].isNotEmpty
                      ? Image.network(
                          _userData!['perfil_url'],
                          fit: BoxFit.cover,
                          width: 65,
                          height: 65,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white70,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.white24,
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.white54,
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.white70,
                          ),
                        ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Center(
                child: Text(
                  "VixScienceMov",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E1F5D),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 110, 31, 93),
              ),
              title: const Text('Editar perfil'),
              onTap: () async {
                Navigator.pop(context); // cierra drawer
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const editarCredencialesScreen(),
                  ),
                );
                // Al volver, recarga los datos del usuario
                _cargarDatosUsuario();
              },
            ),
            const Divider(),
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
          // ─── FILTRO DE CATEGORÍAS ───
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtroCategoria,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  DropdownMenuItem(
                    value: 'Tendencia',
                    child: Text('Tendencia'),
                  ),
                  DropdownMenuItem(value: 'Acción', child: Text('Acción')),
                  DropdownMenuItem(value: 'Miedo', child: Text('Miedo')),
                  DropdownMenuItem(value: 'Aventura', child: Text('Aventura')),
                  DropdownMenuItem(value: 'Clásica', child: Text('Clásica')),
                ],
                onChanged: (val) {
                  setState(() => _filtroCategoria = val!);
                  _loadVideos();
                },
              ),
            ),
          ),
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
    final categories = ['Tendencia', 'Acción', 'Miedo', 'Aventura', 'Clásica'];

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

// ═══════════════════════════════════════════════════════
//  VideoDetalleModal CON REPRODUCTOR MEJORADO ESTILO YOUTUBE
// ═══════════════════════════════════════════════════════
class VideoDetalleModal extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoDetalleModal({super.key, required this.video});

  @override
  State<VideoDetalleModal> createState() => _VideoDetalleModalState();
}

class _VideoDetalleModalState extends State<VideoDetalleModal> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  Future<void> _inicializarReproductor() async {
    final videoUrl = widget.video['video_url'];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      try {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _controller!.initialize();
        _controller!
          ..setLooping(true)
          ..setVolume(1.0);
        _controller!.addListener(() {
          if (mounted) setState(() {});
        });
        if (mounted) setState(() => _isInitialized = true);
      } catch (e) {
        print('Error inicializando video: $e');
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapVideo() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
    _startHideControlsTimer();
  }

  void _seekForward() {
    if (_controller == null) return;
    final newPos = _controller!.value.position + const Duration(seconds: 10);
    _controller!.seekTo(newPos);
    _startHideControlsTimer();
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
    _startHideControlsTimer();
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _startHideControlsTimer();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _launchVideoCompleto(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty || videoUrl == 'null') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay video disponible')));
      return;
    }
    final fixedUrl = videoUrl.replaceAll('dl=0', 'raw=1');
    final uri = Uri.parse(fixedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede abrir el video')),
      );
    }
  }

  Future<void> _launchTrailer(String? trailerUrl) async {
    if (trailerUrl == null || trailerUrl.isEmpty || trailerUrl == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay enlace de trailer disponible')),
      );
      return;
    }
    final fixedUrl = trailerUrl.replaceAll('dl=0', 'raw=1');
    final uri = Uri.parse(fixedUrl);
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
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    // Restaurar orientación y UI al cerrar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ─── WIDGET DEL REPRODUCTOR MEJORADO ───
  Widget _buildVideoPlayer() {
    if (!_isInitialized || _controller == null) {
      return Container(
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
      );
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final isPlaying = _controller!.value.isPlaying;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return ClipRRect(
      borderRadius: _isFullScreen
          ? BorderRadius.zero
          : BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: GestureDetector(
          onTap: _onTapVideo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Video ──
              VideoPlayer(_controller!),

              // ── Overlay oscuro cuando se muestran controles ──
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(color: Colors.black45),
              ),

              // ── Controles centrales ──
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Retroceder 10s
                      _controlBtn(
                        icon: Icons.replay_10,
                        size: 36,
                        onTap: _seekBackward,
                      ),
                      const SizedBox(width: 24),
                      // Play / Pause
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Adelantar 10s
                      _controlBtn(
                        icon: Icons.forward_10,
                        size: 36,
                        onTap: _seekForward,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Barra de progreso + tiempo + fullscreen (abajo) ──
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Slider de progreso
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.red,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.red,
                                overlayColor: Colors.red.withOpacity(0.2),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                trackHeight: 3,
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (val) {
                                  final newPos = Duration(
                                    milliseconds:
                                        (val * duration.inMilliseconds).round(),
                                  );
                                  _controller!.seekTo(newPos);
                                  _startHideControlsTimer();
                                },
                              ),
                            ),
                            // Tiempo + botón fullscreen
                            Row(
                              children: [
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _toggleFullScreen,
                                  child: Icon(
                                    _isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duracion = widget.video['duracion'] ?? 'N/A';
    final edad = widget.video['edad_recomendada'] ?? 'N/A';
    final trailerUrl = widget.video['trailer_url'];
    final videoCompletoUrl = widget.video['video_url'];
    final portadaUrl = widget.video['portada_url'] ?? '';

    // Pantalla completa: solo el reproductor
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: _buildVideoPlayer()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // Portada
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video['titulo'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
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
                      const SizedBox(height: 16),
                      Text(
                        widget.video['descripcion'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _launchVideoCompleto(videoCompletoUrl),
                          icon: const Icon(
                            Icons.play_circle,
                            color: Color.fromARGB(255, 95, 7, 7),
                          ),
                          label: const Text(
                            'Ver película completa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 24),
                      // ─── REPRODUCTOR MEJORADO ───
                      _buildVideoPlayer(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
            // Botón cerrar
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
