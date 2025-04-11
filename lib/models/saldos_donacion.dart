class SaldosDonacion {
  final int saldoId;
  final int donacionId;
  final double montoOriginal;
  final double? montoUtilizado;
  final double saldoDisponible;
  final DateTime? ultimaActualizacion;

  SaldosDonacion({
    required this.saldoId,
    required this.donacionId,
    required this.montoOriginal,
    this.montoUtilizado,
    required this.saldoDisponible,
    this.ultimaActualizacion,
  });

  factory SaldosDonacion.fromJson(Map<String, dynamic> json) {
    return SaldosDonacion(
      saldoId: json['saldoId'],
      donacionId: json['donacionId'],
      montoOriginal: json['montoOriginal'].toDouble(),
      montoUtilizado: json['montoUtilizado']?.toDouble(),
      saldoDisponible: json['saldoDisponible'].toDouble(),
      ultimaActualizacion: json['ultimaActualizacion'] != null 
          ? DateTime.parse(json['ultimaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saldoId': saldoId,
      'donacionId': donacionId,
      'montoOriginal': montoOriginal,
      'montoUtilizado': montoUtilizado,
      'saldoDisponible': saldoDisponible,
      'ultimaActualizacion': ultimaActualizacion?.toIso8601String(),
    };
  }
}