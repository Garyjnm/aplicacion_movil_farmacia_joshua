class ClienteModel {
  final int? idCliente;
  final String nombre;
  final String apellido;

  ClienteModel({
    this.idCliente,
    required this.nombre,
    required this.apellido,
  });
  

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
  return ClienteModel(
    idCliente: json['idCliente'] ?? json['IdCliente'],
    nombre: json['nombre'] ?? json['Nombre'] ?? '',
    apellido: json['apellido'] ?? json['Apellido'] ?? '',
  );
}



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'Nombre': nombre,
      'Apellido': apellido,
    };
    
    if (idCliente != null && idCliente! > 0) {
      data["IdCliente"] = idCliente; 
    }
    
    return data;
  }
}