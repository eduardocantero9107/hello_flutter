
import 'package:flutter/material.dart';

import '../models/pelicula.dart';
import '../services/peliculas_firestore_service.dart';

class AdministracionScreen extends StatefulWidget {
  const AdministracionScreen({super.key});

  @override
  State<AdministracionScreen> createState() =>
      _AdministracionScreenState();
}

class _AdministracionScreenState
    extends State<AdministracionScreen> {
  final _servicio = PeliculasFirestoreService();

  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _anioController = TextEditingController();
  final _directorController = TextEditingController();
  final _generoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagenController = TextEditingController();

  bool _guardando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _anioController.dispose();
    _directorController.dispose();
    _generoController.dispose();
    _descripcionController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  Future<void> _agregarPelicula() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await _servicio.agregarPelicula(
        titulo: _tituloController.text,
        anio: _anioController.text,
        director: _directorController.text,
        genero: _generoController.text,
        descripcion: _descripcionController.text,
        imagenUrl: _imagenController.text,
      );

      if (!mounted) return;

      _formKey.currentState!.reset();

      _tituloController.clear();
      _anioController.clear();
      _directorController.clear();
      _generoController.clear();
      _descripcionController.clear();
      _imagenController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película agregada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la película: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _eliminarPelicula(Pelicula pelicula) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar película'),
        content: Text(
          '¿Deseas eliminar "${pelicula.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || pelicula.firestoreId == null) return;

    try {
      await _servicio.eliminarPelicula(pelicula.firestoreId!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película eliminada correctamente.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $error'),
        ),
      );
    }
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    int maxLineas = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLineas,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar películas'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar película',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _campo('Título', _tituloController),
                  _campo(
                    'Año de estreno',
                    _anioController,
                    tipo: TextInputType.number,
                  ),
                  _campo('Director', _directorController),
                  _campo('Género', _generoController),
                  _campo(
                    'Sinopsis',
                    _descripcionController,
                    maxLineas: 4,
                  ),
                  _campo('URL de imagen', _imagenController),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardando
                          ? null
                          : _agregarPelicula,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: const Text('Guardar película'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Películas registradas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            StreamBuilder<List<Pelicula>>(
              stream: _servicio.obtenerPeliculas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error al cargar películas: ${snapshot.error}',
                  );
                }

                final peliculas = snapshot.data ?? [];

                if (peliculas.isEmpty) {
                  return const Text(
                    'Todavía no hay películas registradas.',
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: peliculas.length,
                  itemBuilder: (context, index) {
                    final pelicula = peliculas[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.movie),
                        title: Text(pelicula.titulo),
                        subtitle: Text(
                          '${pelicula.fechaEstreno} · ${pelicula.genero}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _eliminarPelicula(pelicula),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
