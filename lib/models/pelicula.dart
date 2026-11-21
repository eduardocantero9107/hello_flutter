
class Pelicula {
  final int id;
  final String titulo;
  final String descripcion;
  final String fechaEstreno;
  final double calificacion;
  final String? posterPath;
  final String director;
  final String genero;
  final String? firestoreId;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaEstreno,
    required this.calificacion,
    this.posterPath,
    this.director = '',
    this.genero = '',
    this.firestoreId,
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: json['title'] ?? json['titulo'] ?? 'Sin título',
      descripcion:
          json['overview'] ?? json['descripcion'] ?? 'Sin descripción',
      fechaEstreno:
          json['release_date'] ?? json['fechaEstreno'] ?? '',
      calificacion:
          (json['vote_average'] as num?)?.toDouble() ??
          (json['calificacion'] as num?)?.toDouble() ??
          0.0,
      posterPath: json['poster_path'] ??
          json['posterPath'] ??
          json['imagenUrl'],
      director: json['director'] ?? '',
      genero: json['genero'] ?? '',
    );
  }

  factory Pelicula.fromFirestore(
    String documentId,
    Map<String, dynamic> datos,
  ) {
    return Pelicula(
      id: (datos['id'] as num?)?.toInt() ?? 0,
      titulo: datos['titulo'] ?? 'Sin título',
      descripcion: datos['descripcion'] ?? 'Sin descripción',
      fechaEstreno: datos['fechaEstreno'] ?? '',
      calificacion:
          (datos['calificacion'] as num?)?.toDouble() ?? 0.0,
      posterPath: datos['imagenUrl'],
      director: datos['director'] ?? '',
      genero: datos['genero'] ?? '',
      firestoreId: documentId,
    );
  }

  String? get imagenUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return null;
    }

    if (posterPath!.startsWith('http://') ||
        posterPath!.startsWith('https://')) {
      return posterPath;
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
