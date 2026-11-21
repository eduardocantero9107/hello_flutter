
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pelicula.dart';

class PeliculasFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _peliculas =>
      _firestore.collection('peliculas');

  // Registrar una película en Firestore.
  Future<void> agregarPelicula({
    required String titulo,
    required String anio,
    required String director,
    required String genero,
    required String descripcion,
    required String imagenUrl,
  }) async {
    await _peliculas.add({
      'id': DateTime.now().microsecondsSinceEpoch,
      'titulo': titulo.trim(),
      'fechaEstreno': anio.trim(),
      'director': director.trim(),
      'genero': genero.trim(),
      'descripcion': descripcion.trim(),
      'imagenUrl': imagenUrl.trim(),
      'calificacion': 0.0,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  // Obtener las películas guardadas en tiempo real.
  Stream<List<Pelicula>> obtenerPeliculas() {
    return _peliculas.snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        return Pelicula.fromFirestore(
          documento.id,
          documento.data(),
        );
      }).toList();
    });
  }

  // Eliminar una película por su identificador de Firestore.
  Future<void> eliminarPelicula(String documentId) async {
    await _peliculas.doc(documentId).delete();
  }
}
