
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar usuario y guardar sus datos en Firestore.
  Future<UserCredential> registrarUsuario({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final credencial = EmailAuthProvider.credential(
      email: correo.trim(),
      password: password,
    );

    final usuarioActual = _auth.currentUser;

    UserCredential resultado;

    // Si existe una sesión anónima, la vinculamos
    // para conservar el UID y los favoritos existentes.
    if (usuarioActual != null && usuarioActual.isAnonymous) {
      resultado = await usuarioActual.linkWithCredential(credencial);
    } else {
      resultado = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: password,
      );
    }

    final usuario = resultado.user!;

    await usuario.updateDisplayName(nombre.trim());

    await _firestore.collection('usuarios').doc(usuario.uid).set({
      'nombre': nombre.trim(),
      'correo': correo.trim(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return resultado;
  }

  // Iniciar sesión con correo y contraseña.
  Future<UserCredential> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    final resultado = await _auth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: password,
    );

    return resultado;
  }

  // Cerrar sesión.
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Obtener el usuario actual.
  User? get usuarioActual => _auth.currentUser;

  // Escuchar cambios en la sesión.
  Stream<User?> get cambiosSesion => _auth.authStateChanges();
}
