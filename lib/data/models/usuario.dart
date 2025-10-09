class Usuario {
  final int? idUsuario;
  final String nombres;
  final String apellidos;
  final String nombreUsuario;
  final String? contrasena; // <-- usamos "contrasena" (sin ñ) en Dart
  final int idRol;
  final int? estado;

  Usuario({
    this.idUsuario,
    required this.nombres,
    required this.apellidos,
    required this.nombreUsuario,
    this.contrasena,
    required this.idRol,
    this.estado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      nombreUsuario: json['nombreUsuario'],
      contrasena: json['contraseña'], // 👈 Aquí seguimos leyendo "contraseña" del backend
      idRol: json['idRol'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nombres': nombres,
      'apellidos': apellidos,
      'nombreUsuario': nombreUsuario,
      'contraseña': contrasena, // 👈 Al enviar, también usamos la clave "contraseña"
      'idRol': idRol,
      'estado': estado,
    };
  }
}
