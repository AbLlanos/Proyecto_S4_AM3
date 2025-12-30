import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto_s4_am3/main.dart';
import 'package:proyecto_s4_am3/screens/editarDatosVideoScreen.dart'
    hide supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class catalogoScreen extends StatefulWidget {
  const catalogoScreen({super.key});

  @override
  State<catalogoScreen> createState() => _catalogoScreenState();
}

class _catalogoScreenState extends State<catalogoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPublicTab = true;
  String _filtroCategoria = 'todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ← NUEVA: Obtener emails de todos los autores
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

  //Funcion para leer videos publicos
  Future<List<Map<String, dynamic>>> leerVideosPublicos() async {
    List<Map<String, dynamic>> videos = [];

    if (_filtroCategoria == 'todos') {
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('es_publica', true)
          .order('fecha_subida', ascending: false)
          .limit(50);
      videos = List<Map<String, dynamic>>.from(response);
    } else {
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('es_publica', true)
          .eq('categoria', _filtroCategoria)
          .order('fecha_subida', ascending: false)
          .limit(50);
      videos = List<Map<String, dynamic>>.from(response);
    }

    final userIds = videos.map((v) => v['user_id'].toString()).toSet();
    final emails = await _getAllUserEmails(userIds);

    for (var video in videos) {
      video['author_email'] =
          emails[video['user_id'].toString()] ?? 'Cargando...';
    }
    return videos;
  }

  //Funcion para leer mis videos
  // Leer MIS videos (privados + públicos)
  Future<List<Map<String, dynamic>>> leerMisVideos() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> videos = [];

    if (_filtroCategoria == 'todos') {
      // ← TODOS mis videos (públicos + privados)
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('user_id', user.id)
          .order('fecha_subida', ascending: false);
      videos = List<Map<String, dynamic>>.from(response);
    } else {
      // ← SOLO mis videos de categoría específica
      final response = await supabase
          .from('contenidoVix')
          .select()
          .eq('user_id', user.id)
          .eq('categoria', _filtroCategoria)
          .order('fecha_subida', ascending: false);
      videos = List<Map<String, dynamic>>.from(response);
    }

    for (var video in videos) {
      video['author_email'] = 'Propietario';
    }
    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromRGBO(255, 255, 255, 0.835),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
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
          // ← Dropdown filtro categoría
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
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
                  DropdownMenuItem(value: 'Tendencia', child: Text('Tendencia')),
                  DropdownMenuItem(value: 'Acción', child: Text('Acción')),
                  DropdownMenuItem(
                    value: 'Miedo',
                    child: Text('Miedo'),
                  ),
                  DropdownMenuItem(value: 'Aventura', child: Text('Aventura')),
                  DropdownMenuItem(value: 'Clásica', child: Text('Clásica')),
                ],
                onChanged: (val) => setState(() => _filtroCategoria = val!),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Catálogo disponible'),
            Tab(text: 'Películas subidas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListarVideos(leerVideosPublicos, isOwner: false),
          ListarVideos(leerMisVideos, isOwner: true),
        ],
      ),
    );
  }
}

class ListarVideos extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchVideos;
  final bool isOwner;

  const ListarVideos(this.fetchVideos, {super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return VideoCard(item: item, isOwner: isOwner);
              },
            );
          } else {
            return const Center(
              child: Text(
                "No hay videos disponibles",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isOwner;

  String _getUserName(dynamic userId) {
    if (userId == null) return 'Anónimo';
    final id = userId.toString();
    return id.length > 8
        ? '${id.substring(0, 4)}...${id.substring(id.length - 4)}'
        : id;
  }

  const VideoCard({super.key, required this.item, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final fechaSubida = item['fecha_subida'] != null
        ? DateTime.parse(item['fecha_subida']).toLocal()
        : null;
    final duracion = item['duracion'] ?? 'N/A';
    final edad = item['edad_recomendada'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 8,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _mostrarDetalle(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['titulo'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fechaSubida != null)
                    Text(
                      '${fechaSubida.day}/${fechaSubida.month}/${fechaSubida.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['portada_url'] ?? '',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(height: 180, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 8),

              // Auto
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.amber[400], size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Autor: ${item['author_email'] ?? _getUserName(item['user_id'])}',

                        style: TextStyle(
                          color: Colors.amber[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ← Categoría (DESPUÉS del autor)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.blue[400], size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Categoría: ${item['categoria'] ?? 'Sin categoría'}',
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                item['descripcion'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$duracion min',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.confirmation_number,
                    color: Colors.white70,
                    size: 16,
                  ),
                  Text(
                    ' $edad+',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              if (isOwner) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editarVideo(context, item),
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      label: const Text(
                        'Editar',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _eliminarVideo(context, item),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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

  void _editarVideo(BuildContext context, Map<String, dynamic> video) {
    print('_editarVideo INICIADO');
    print('video data: $video');

    Navigator.pushNamed(context, '/editarVideo', arguments: video);

    print('🚀 _editarVideo: Navigator.pushNamed ejecutado');
  }

  Future<void> _eliminarVideo(
    BuildContext context,
    Map<String, dynamic> video,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Eliminar video',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de eliminar "${video['titulo']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await supabase.from('contenidoVix').delete().eq('id', video['id']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Video eliminado correctamente'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error al eliminar: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}

class VideoDetalleModal extends StatefulWidget {
  final Map<String, dynamic> video;
  const VideoDetalleModal({super.key, required this.video});

  @override
  State<VideoDetalleModal> createState() => _VideoDetalleModalState();
}

class _VideoDetalleModalState extends State<VideoDetalleModal> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  final bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  Future<void> _inicializarReproductor() async {
    final videoUrl = widget.video['video_url'];
    if (videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Colors.black),
      child: Column(
        children: [
          // PLAYER DE VIDEO
          if (_isInitialized && _controller != null)
            Container(
              height: 250,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  IconButton(
                    iconSize: 64,
                    icon: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 64,
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
              ),
            )
          else
            Container(
              height: 250,
              color: Colors.grey[800],
              child: const Icon(Icons.movie, color: Colors.white70, size: 64),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.video['titulo'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.video['portada_url'] ?? '',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(height: 200, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 20),
                if (fechaSubida != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Subido: ${fechaSubida.day}/${fechaSubida.month}/${fechaSubida.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.video['descripcion'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _isInitialized
                          ? () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            }
                          : null,
                      icon: const Icon(Icons.movie),
                      label: const Text(
                        'Reproducir o pausar video',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Duración: $duracion min • $edad+',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
