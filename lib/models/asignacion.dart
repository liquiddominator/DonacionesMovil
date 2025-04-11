class Asignacion {
  final int asignacionId;
  final int campaniaId;
  final String descripcion;
  final double monto;
  final DateTime? fechaAsignacion;
  final int usuarioId;
  final String? comprobante;

  Asignacion({
    required this.asignacionId,
    required this.campaniaId,
    required this.descripcion,
    required this.monto,
    this.fechaAsignacion,
    required this.usuarioId,
    this.comprobante,
  });

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      asignacionId: json['asignacionId'],
      campaniaId: json['campaniaId'],
      descripcion: json['descripcion'],
      monto: json['monto'].toDouble(),
      fechaAsignacion: json['fechaAsignacion'] != null 
          ? DateTime.parse(json['fechaAsignacion']) 
          : null,
      usuarioId: json['usuarioId'],
      comprobante: json['comprobante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asignacionId': asignacionId,
      'campaniaId': campaniaId,
      'descripcion': descripcion,
      'monto': monto,
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
      'usuarioId': usuarioId,
      'comprobante': comprobante,
    };
  }
}