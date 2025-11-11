class ApiConstants {
  static const baseUrl = 'http://apidonacionesbeni.somee.com'; // SQL
  static const mongoBaseUrl = 'http://www.apimongo.somee.com'; // MongoDB

  static const apiUrl = '$baseUrl/api';
  static const mongoApiUrl = '$mongoBaseUrl/api';

  static const userEndpoint = '$apiUrl/Usuarios';
  static const campaniaEndpoint = '$apiUrl/Campanias';
  static const donacionEndpoint = '$apiUrl/Donaciones';
  static const campaniaDonantesCountEndpoint = '$donacionEndpoint/campania';
  static const saldosDonacionEndpoint = '$apiUrl/SaldosDonaciones';
  static const mensajeEndpoint = '$apiUrl/Mensajes';
  static const respuestaMensajeEndpoint = '$apiUrl/RespuestasMensajes';
  static const estadoEndpoint = '$apiUrl/Estadoes';
  static const donacionAsignacionEndpoint = '$apiUrl/DonacionesAsignaciones';
  static const detalleAsignacionEndpoint = '$apiUrl/DetallesAsignacions';
  static const asignacionEndpoint = '$apiUrl/Asignaciones';
  static const rolesEndpoint = '$apiUrl/Roles';
  static const usuariosRolesEndpoint = '$apiUrl/UsuariosRoles';

  static const comentarioEndpoint = '$mongoApiUrl/Comentarios';
}