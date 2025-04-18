class DonacionAsignacion {
  final int donacionAsignacionId;
  final int donacionId;
  final int asignacionId;
  double montoAsignado;
  final DateTime? fechaAsignacion;

  DonacionAsignacion({
    required this.donacionAsignacionId,
    required this.donacionId,
    required this.asignacionId,
    required this.montoAsignado,
    this.fechaAsignacion,
  });

  factory DonacionAsignacion.fromJson(Map<String, dynamic> json) {
    return DonacionAsignacion(
      donacionAsignacionId: json['donacionAsignacionId'],
      donacionId: json['donacionId'],
      asignacionId: json['asignacionId'],
      montoAsignado: json['montoAsignado'].toDouble(),
      fechaAsignacion: json['fechaAsignacion'] != null 
          ? DateTime.parse(json['fechaAsignacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donacionAsignacionId': donacionAsignacionId,
      'donacionId': donacionId,
      'asignacionId': asignacionId,
      'montoAsignado': montoAsignado,
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
    };
  }
}