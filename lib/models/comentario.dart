class Comentario {
  final String? id;
  final int usuarioId;
  final String nombre;
  final String email;
  final String texto;
  final int calificacion;
  final DateTime fechaCreacion;
  final int? donacionId;

  Comentario({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.email,
    required this.texto,
    required this.calificacion,
    required this.fechaCreacion,
    this.donacionId,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['_id'] ?? json['id'],
      usuarioId: json['usuarioId'],
      nombre: json['nombre'],
      email: json['email'],
      texto: json['texto'],
      calificacion: json['calificacion'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      donacionId: json['donacionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'email': email,
      'texto': texto,
      'calificacion': calificacion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'donacionId': donacionId,
    };
  }
}
