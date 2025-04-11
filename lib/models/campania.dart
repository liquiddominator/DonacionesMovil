class Campania {
  final int campaniaId;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final double metaRecaudacion;
  final double? montoRecaudado;
  final int usuarioIdcreador;
  final bool? activa;
  final DateTime? fechaCreacion;

  Campania({
    required this.campaniaId,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.metaRecaudacion,
    this.montoRecaudado,
    required this.usuarioIdcreador,
    this.activa,
    this.fechaCreacion,
  });

  factory Campania.fromJson(Map<String, dynamic> json) {
    return Campania(
      campaniaId: json['campaniaId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: json['fechaFin'] != null 
          ? DateTime.parse(json['fechaFin']) 
          : null,
      metaRecaudacion: json['metaRecaudacion'].toDouble(),
      montoRecaudado: json['montoRecaudado']?.toDouble(),
      usuarioIdcreador: json['usuarioIdcreador'],
      activa: json['activa'],
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaniaId': campaniaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'metaRecaudacion': metaRecaudacion,
      'montoRecaudado': montoRecaudado,
      'usuarioIdcreador': usuarioIdcreador,
      'activa': activa,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }
}