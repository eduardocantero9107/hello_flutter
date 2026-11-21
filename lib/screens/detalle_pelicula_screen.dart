
import 'package:flutter/material.dart';

import '../models/pelicula.dart';

class DetallePeliculaScreen extends StatelessWidget {
  final Pelicula pelicula;

  const DetallePeliculaScreen({
    super.key,
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de película'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la película.
            SizedBox(
              width: double.infinity,
              height: 420,
              child: pelicula.imagenUrl != null
                  ? Image.network(
                      pelicula.imagenUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.movie, size: 100),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.movie, size: 100),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pelicula.titulo,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _dato(
                    'Año de estreno',
                    pelicula.fechaEstreno.isEmpty
                        ? 'No disponible'
                        : pelicula.fechaEstreno,
                  ),

                  _dato(
                    'Director',
                    pelicula.director.isEmpty
                        ? 'No disponible'
                        : pelicula.director,
                  ),

                  _dato(
                    'Género',
                    pelicula.genero.isEmpty
                        ? 'No disponible'
                        : pelicula.genero,
                  ),

                  _dato(
                    'Calificación',
                    pelicula.calificacion.toStringAsFixed(1),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    pelicula.descripcion.isEmpty
                        ? 'Sinopsis no disponible.'
                        : pelicula.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$etiqueta:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
