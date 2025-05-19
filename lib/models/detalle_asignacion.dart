class DetalleAsignacion {
  final int detalleId;
  final int asignacionId;
  final String concepto;
  final int cantidad;
  final double precioUnitario;
  final String? imagenUrl;

  DetalleAsignacion({
  required this.detalleId,
  required this.asignacionId,
  required this.concepto,
  required this.cantidad,
  required this.precioUnitario,
  this.imagenUrl,
});

factory DetalleAsignacion.fromJson(Map<String, dynamic> json) {
  return DetalleAsignacion(
    detalleId: json['detalleId'],
    asignacionId: json['asignacionId'],
    concepto: json['concepto'],
    cantidad: json['cantidad'],
    precioUnitario: json['precioUnitario'].toDouble(),
    imagenUrl: json['imagenUrl'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'detalleId': detalleId,
    'asignacionId': asignacionId,
    'concepto': concepto,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'imagenUrl': imagenUrl,
  };
}
}