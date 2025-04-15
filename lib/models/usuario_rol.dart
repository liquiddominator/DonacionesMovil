class UsuarioRol {
  final int usuarioRolId;
  final int usuarioId;
  final int rolId;
  final DateTime? fechaAsignacion;

  UsuarioRol({
    required this.usuarioRolId,
    required this.usuarioId,
    required this.rolId,
    this.fechaAsignacion,
  });

  factory UsuarioRol.fromJson(Map<String, dynamic> json) {
    return UsuarioRol(
      usuarioRolId: json['usuarioRolId'],
      usuarioId: json['usuarioId'],
      rolId: json['rolId'],
      fechaAsignacion: json['fechaAsignacion'] != null 
          ? DateTime.parse(json['fechaAsignacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioRolId': usuarioRolId,
      'usuarioId': usuarioId,
      'rolId': rolId,
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
    };
  }
}