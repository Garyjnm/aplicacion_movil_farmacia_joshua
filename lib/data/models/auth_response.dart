class AuthResponse { // Modelo para la respuesta de autenticación
    final String token;
    final int idUsuario;
    final String nombres;
    final String apellidos;
    final String nombreUsuario;
    final int idRol;

    AuthResponse({ // Constructor con parámetros nombrados
        required this.token,
        required this.idUsuario,
        required this.nombres,
        required this.apellidos,
        required this.nombreUsuario,
        required this.idRol,
        
        });
    
    factory AuthResponse.fromJson(Map<String, dynamic> json) { // Método factory para crear una instancia desde JSON 
        return AuthResponse(
            token: json['token'] ?? '', //Utilizamos el operador logico por si nos llega vacio el campo
            idUsuario: json['idUsuario'] ?? 0, //Utilizamos el operador logico por si nos llega vacio el campo
            nombres: json['nombres'] ?? '',
            apellidos: json['apellidos'] ?? '',
            nombreUsuario: json['nombreUsuario'] ?? '',
            idRol: json['idRol'] ?? 0,
        );
    }
}