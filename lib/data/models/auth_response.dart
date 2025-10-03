class AuthResponse {
    final String token;
    final int idUsuario;
    final String nombres;
    final String apellidos;
    final String nombreUsuario;
    final int idRol;

    AuthResponse({
        required this.token,
        required this.idUsuario,
        required this.nombres,
        required this.apellidos,
        required this.nombreUsuario,
        required this.idRol,
        
        });
    
    factory AuthResponse.fromJson(Map<String, dynamic> json) {
        return AuthResponse(
            token: json['token'] ?? '',
            idUsuario: json['idUsuario'] ?? 0,
            nombres: json['nombres'] ?? '',
            apellidos: json['apellidos'] ?? '',
            nombreUsuario: json['nombreUsuario'] ?? '',
            idRol: json['idRol'] ?? 0,
        );
    }
}