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
      idCategoria: json['IdCategoria'],
      nombre: json['Nombre'],
      descripcion: json['Descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "IdCategoria": idCategoria,
      "Nombre": nombre,
      "Descripcion": descripcion,
    };
  }
}
