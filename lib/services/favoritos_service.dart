
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pelicula.dart';

class FavoritosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtiene la colección de favoritos del usuario actual.
  CollectionReference<Map<String, dynamic>> get _favoritos {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw StateError('No hay un usuario autenticado.');
    }

    return _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('favoritos');
  }

  // Guarda una película como favorita.
  Future<void> guardarFavorito(Pelicula pelicula) async {
    await _favoritos.doc(pelicula.id.toString()).set({
      'title': pelicula.titulo,
      'overview': pelicula.descripcion,
      'release_date': pelicula.fechaEstreno,
      'vote_average': pelicula.calificacion,
      'poster_path': pelicula.posterPath,
    });
  }

  // Elimina una película de favoritos.
  Future<void> eliminarFavorito(int peliculaId) async {
    await _favoritos.doc(peliculaId.toString()).delete();
  }

  // Obtiene en tiempo real la lista de favoritos.
  Stream<List<Pelicula>> obtenerFavoritos() {
    return _favoritos.snapshots().map((snapshot) {
      return snapshot.docs.map((documento) {
        final datos = documento.data();

        return Pelicula.fromJson({
          ...datos,
          'id': int.tryParse(documento.id) ?? 0,
        });
      }).toList();
    });
  }
}
