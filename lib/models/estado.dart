class Estado {
  final int estadoId;
  final String nombre;
  final String? descripcion;

  Estado({
    required this.estadoId,
    required this.nombre,
    this.descripcion,
  });

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      estadoId: json['estadoId'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estadoId': estadoId,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}