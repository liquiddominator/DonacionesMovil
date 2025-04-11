class Donacion {
  final int donacionId;
  final int? usuarioId;
  final int campaniaId;
  final double monto;
  final String tipoDonacion;
  final String? descripcion;
  final DateTime? fechaDonacion;
  final int estadoId;
  final bool? esAnonima;

  Donacion({
    required this.donacionId,
    this.usuarioId,
    required this.campaniaId,
    required this.monto,
    required this.tipoDonacion,
    this.descripcion,
    this.fechaDonacion,
    required this.estadoId,
    this.esAnonima,
  });

  factory Donacion.fromJson(Map<String, dynamic> json) {
    return Donacion(
      donacionId: json['donacionId'],
      usuarioId: json['usuarioId'],
      campaniaId: json['campaniaId'],
      monto: json['monto'].toDouble(),
      tipoDonacion: json['tipoDonacion'],
      descripcion: json['descripcion'],
      fechaDonacion: json['fechaDonacion'] != null 
          ? DateTime.parse(json['fechaDonacion']) 
          : null,
      estadoId: json['estadoId'],
      esAnonima: json['esAnonima'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donacionId': donacionId,
      'usuarioId': usuarioId,
      'campaniaId': campaniaId,
      'monto': monto,
      'tipoDonacion': tipoDonacion,
      'descripcion': descripcion,
      'fechaDonacion': fechaDonacion?.toIso8601String(),
      'estadoId': estadoId,
      'esAnonima': esAnonima,
    };
  }
}