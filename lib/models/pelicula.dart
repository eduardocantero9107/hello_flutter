class Pelicula {
  final int id;
  final String titulo;
  final String descripcion;
  final String fechaEstreno;
  final double calificacion;
  final String? posterPath;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaEstreno,
    required this.calificacion,
    this.posterPath,
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: json['title'] ?? 'Sin título',
      descripcion: json['overview'] ?? 'Sin descripción',
      fechaEstreno: json['release_date'] ?? '',
      calificacion:
          (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
    );
  }

  String? get imagenUrl {
    if (posterPath == null || posterPath!.isEmpty) {
      return null;
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}