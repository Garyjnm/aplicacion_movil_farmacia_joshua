class Categoria {
  final int? idCategoria;
  final String nombre;
  final String descripcion;

  Categoria({
    this.idCategoria,
    required this.nombre,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['idCategoria'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idCategoria": idCategoria,
      "nombre": nombre,
      "descripcion": descripcion,
    };
  }
}
