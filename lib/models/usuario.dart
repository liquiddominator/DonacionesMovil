class Usuario {
  final int usuarioId;
  final String email;
  final String contrasena;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? imagenUrl;
  final bool? activo;
  final DateTime? fechaRegistro;

  Usuario({
  required this.usuarioId,
  required this.email,
  required this.contrasena,
  required this.nombre,
  required this.apellido,
  this.telefono,
  this.activo,
  this.fechaRegistro,
  this.imagenUrl,
});

factory Usuario.fromJson(Map<String, dynamic> json) {
  return Usuario(
    usuarioId: json['usuarioId'],
    email: json['email'],
    contrasena: json['contrasena'],
    nombre: json['nombre'],
    apellido: json['apellido'],
    telefono: json['telefono'],
    activo: json['activo'],
    fechaRegistro: json['fechaRegistro'] != null 
        ? DateTime.parse(json['fechaRegistro']) 
        : null,
    imagenUrl: json['imagenUrl'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'usuarioId': usuarioId,
    'email': email,
    'contrasena': contrasena,
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'activo': activo,
    'fechaRegistro': fechaRegistro?.toIso8601String(),
    'imagenUrl': imagenUrl,
  };
}
}