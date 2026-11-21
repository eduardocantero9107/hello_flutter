
import 'package:flutter/material.dart';

import '../models/pelicula.dart';
import '../services/auth_service.dart';
import '../services/pelicula_service.dart';
import '../services/favoritos_service.dart';
import '../services/peliculas_firestore_service.dart';

import 'favoritos_screen.dart';
import 'detalle_pelicula_screen.dart';
import 'administracion_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final PeliculaService _servicio = PeliculaService();
  final FavoritosService _favoritosServicio = FavoritosService();
  final PeliculasFirestoreService _firestoreServicio =
      PeliculasFirestoreService();

  late Future<List<Pelicula>> _peliculasFuture;

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  void _cargarPeliculas() {
    _peliculasFuture = _servicio.obtenerPeliculasPopulares();
  }

  void _recargarPeliculas() {
    setState(() {
      _cargarPeliculas();
    });
  }

  void _abrirDetalles(Pelicula pelicula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetallePeliculaScreen(pelicula: pelicula),
      ),
    );
  }

  void _abrirFavoritos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritosScreen(),
      ),
    );
  }

  void _abrirAdministracion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdministracionScreen(),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await AuthService().cerrarSesion();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible cerrar sesión: $error'),
        ),
      );
    }
  }

  Future<void> _alternarFavorito(
    Pelicula pelicula,
    bool esFavorito,
  ) async {
    try {
      if (esFavorito) {
        await _favoritosServicio.eliminarFavorito(pelicula.id);
      } else {
        await _favoritosServicio.guardarFavorito(pelicula);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esFavorito
                ? 'Película eliminada de favoritos.'
                : 'Película agregada a favoritos.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible actualizar favoritos: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menú principal',
            icon: const Icon(Icons.menu),
            onSelected: (opcion) {
              switch (opcion) {
                case 'catalogo':
                  _recargarPeliculas();
                  break;
                case 'favoritos':
                  _abrirFavoritos();
                  break;
                case 'administracion':
                  _abrirAdministracion();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'catalogo',
                child: Row(
                  children: [
                    Icon(Icons.movie, color: Colors.blueGrey),
                    SizedBox(width: 10),
                    Text('Catálogo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favoritos',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Mis favoritos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'administracion',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blueGrey),
                    SizedBox(width: 10),
                    Text('Administrar películas'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _recargarPeliculas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar catálogo',
          ),
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<Pelicula>>(
        future: _peliculasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No fue posible cargar las películas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _recargarPeliculas,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final peliculasTMDB = snapshot.data ?? [];

          return StreamBuilder<List<Pelicula>>(
            stream: _firestoreServicio.obtenerPeliculas(),
            builder: (context, firestoreSnapshot) {
              final peliculasFirestore =
                  firestoreSnapshot.data ?? [];

              final peliculas = [
                ...peliculasTMDB,
                ...peliculasFirestore,
              ];

              if (peliculas.isEmpty &&
                  firestoreSnapshot.connectionState ==
                      ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (peliculas.isEmpty) {
                return const Center(
                  child: Text('No hay películas disponibles.'),
                );
              }

              return StreamBuilder<List<Pelicula>>(
                stream: _favoritosServicio.obtenerFavoritos(),
                builder: (context, favoritosSnapshot) {
                  final favoritos = favoritosSnapshot.data ?? [];

                  return Column(
                    children: [
                      if (firestoreSnapshot.hasError)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'No se pudieron cargar las películas guardadas.',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.52,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: peliculas.length,
                          itemBuilder: (context, index) {
                            final pelicula = peliculas[index];

                            final esFavorito = favoritos.any(
                              (favorito) =>
                                  favorito.id == pelicula.id,
                            );

                            return Card(
                              clipBehavior: Clip.antiAlias,
                              color: Colors.blueGrey.shade900,
                              child: InkWell(
                                onTap: () => _abrirDetalles(pelicula),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          pelicula.imagenUrl != null
                                              ? Image.network(
                                                  pelicula.imagenUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons.movie,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.movie,
                                                    size: 50,
                                                  ),
                                                ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.65),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed:
                                                    favoritosSnapshot.hasError
                                                        ? null
                                                        : () =>
                                                            _alternarFavorito(
                                                              pelicula,
                                                              esFavorito,
                                                            ),
                                                icon: Icon(
                                                  esFavorito
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: esFavorito
                                                      ? Colors.redAccent
                                                      : Colors.white,
                                                ),
                                                tooltip: esFavorito
                                                    ? 'Quitar de favoritos'
                                                    : 'Agregar a favoritos',
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.7),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Ver detalles',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pelicula.titulo,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Estreno: ${pelicula.fechaEstreno.isEmpty ? 'No disponible' : pelicula.fechaEstreno}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 17,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pelicula.calificacion
                                                    .toStringAsFixed(1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
