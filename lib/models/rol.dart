class Rol {
  final int rolId;
  final String nombre;
  final String? descripcion;

  Rol({
    required this.rolId,
    required this.nombre,
    this.descripcion,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      rolId: json['rolId'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rolId': rolId,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}