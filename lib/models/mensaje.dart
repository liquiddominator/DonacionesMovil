class Mensaje {
  final int mensajeId;
  final int usuarioOrigen;
  final int? usuarioDestino;
  final String asunto;
  final String contenido;
  final DateTime? fechaEnvio;
  final bool? leido;
  final bool? respondido;

  Mensaje({
    required this.mensajeId,
    required this.usuarioOrigen,
    this.usuarioDestino,
    required this.asunto,
    required this.contenido,
    this.fechaEnvio,
    this.leido,
    this.respondido,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      mensajeId: json['mensajeId'],
      usuarioOrigen: json['usuarioOrigen'],
      usuarioDestino: json['usuarioDestino'],
      asunto: json['asunto'],
      contenido: json['contenido'],
      fechaEnvio: json['fechaEnvio'] != null 
          ? DateTime.parse(json['fechaEnvio']) 
          : null,
      leido: json['leido'],
      respondido: json['respondido'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensajeId': mensajeId,
      'usuarioOrigen': usuarioOrigen,
      'usuarioDestino': usuarioDestino,
      'asunto': asunto,
      'contenido': contenido,
      'fechaEnvio': fechaEnvio?.toIso8601String(),
      'leido': leido,
      'respondido': respondido,
    };
  }
}