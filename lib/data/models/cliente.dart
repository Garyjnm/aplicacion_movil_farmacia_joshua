class Cliente {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
    );
  }

  String get nombreCompleto => '$nombre $direccion';
}