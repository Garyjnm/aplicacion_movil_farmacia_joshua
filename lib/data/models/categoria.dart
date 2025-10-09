class Categoria {
  final int? idCategoria;
  final String nombre;
  final String descripcion;

  Categoria({
    this.idCategoria,
    required this.nombre,
    required this.descripcion,
  });

  // Crear objeto desde JSON (respuesta de la API)
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['idCategoria'], 
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
    if (idCategoria != null) {
      data["IdCategoria"] = idCategoria; // Mantener int
    }

    return data;
  }
}
