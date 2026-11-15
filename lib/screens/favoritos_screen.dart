
import 'package:flutter/material.dart';

import '../models/pelicula.dart';
import '../services/favoritos_service.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritosServicio = FavoritosService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis películas favoritas'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Pelicula>>(
        stream: favoritosServicio.obtenerFavoritos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('No fue posible cargar tus favoritos.'),
            );
          }

          final favoritos = snapshot.data ?? [];

          if (favoritos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Todavía no tienes películas favoritas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final pelicula = favoritos[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                color: Colors.blueGrey.shade900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: pelicula.imagenUrl != null
                            ? Image.network(
                                pelicula.imagenUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: const TextStyle(fontSize: 11),
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
                                pelicula.calificacion.toStringAsFixed(1),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await favoritosServicio
                                        .eliminarFavorito(pelicula.id);

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Película eliminada de favoritos.',
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No fue posible eliminarla: $error',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Eliminar de favoritos',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
