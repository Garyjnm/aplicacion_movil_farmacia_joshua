class Roles {
  final int? idRol;
  final String nombre;
  final String descripcion;

  Roles({this.idRol, required this.nombre, required this.descripcion});

  // Crear objeto desde JSON (respuesta de la API)
  factory Roles.fromJson(Map<String, dynamic> json) {
    return Roles(
      idRol: json['idRoles'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  // Convertir objeto a JSON (para enviar a la API)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "Nombre": nombre,
      "Descripcion": descripcion,
    };

    // Solo incluir IdCategoria si no es null (para actualizaciones)
    if (idRol != null) {
      data["IdRol"] = idRol; // Mantener int
    }

    return data;
  }
}
