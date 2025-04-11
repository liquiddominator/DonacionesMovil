class RespuestaMensaje {
  final int respuestaId;
  final int mensajeId;
  final int usuarioId;
  final String contenido;
  final DateTime? fechaRespuesta;

  RespuestaMensaje({
    required this.respuestaId,
    required this.mensajeId,
    required this.usuarioId,
    required this.contenido,
    this.fechaRespuesta,
  });

  factory RespuestaMensaje.fromJson(Map<String, dynamic> json) {
    return RespuestaMensaje(
      respuestaId: json['respuestaId'],
      mensajeId: json['mensajeId'],
      usuarioId: json['usuarioId'],
      contenido: json['contenido'],
      fechaRespuesta: json['fechaRespuesta'] != null 
          ? DateTime.parse(json['fechaRespuesta']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'respuestaId': respuestaId,
      'mensajeId': mensajeId,
      'usuarioId': usuarioId,
      'contenido': contenido,
      'fechaRespuesta': fechaRespuesta?.toIso8601String(),
    };
  }
}