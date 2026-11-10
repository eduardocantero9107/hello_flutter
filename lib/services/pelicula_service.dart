import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/pelicula.dart';

class PeliculaService {
  static const String _accessToken =
      String.fromEnvironment('TMDB_ACCESS_TOKEN');

  Future<List<Pelicula>> obtenerPeliculasPopulares() async {
    if (_accessToken.isEmpty) {
      throw Exception(
        'No se ha configurado el token de TMDB.',
      );
    }

    final url = Uri.https(
      'api.themoviedb.org',
      '/3/movie/popular',
      {
        'language': 'es-MX',
        'page': '1',
      },
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> datos =
          jsonDecode(response.body);

      final List<dynamic> resultados = datos['results'];

      return resultados
          .map((json) => Pelicula.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Error HTTP ${response.statusCode}: '
        'No se pudieron obtener las películas.',
      );
    }
  }
}