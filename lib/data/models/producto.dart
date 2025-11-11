class ProductoModel {
  final int? almcId;
  final int? almcDetalleId;
  final int? almcProveedorId;
  final String? almcLote;
  final int? almcExistencia;
  final double? almcPrecioCompra;
  final double? almcPrecioVenta;
  final bool? almcEstado;

  final String? nombreProducto; 
  final String? detalleDescripcion; 
  final DateTime? detalleFechaVencimiento;


  ProductoModel({
    this.almcId,
    this.almcDetalleId,
    this.almcProveedorId,
    this.almcLote,
    this.almcExistencia,
    this.almcPrecioCompra,
    this.almcPrecioVenta,
    this.almcEstado,
    this.nombreProducto, 
    this.detalleDescripcion,
    this.detalleFechaVencimiento,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      almcId: json['Almc_Id'] as int?,
      almcDetalleId: json['Almc_Detalle_Id'] as int?,
      almcProveedorId: json['Almc_Proveedor_Id'] as int?,
      almcLote: (json['Almc_Lote'] as String?) ?? '',
      almcExistencia: json['Almc_Existencia'] as int?,
      almcPrecioCompra: (json['Almc_PrecioCompra'] as num?)?.toDouble(),
      almcPrecioVenta: (json['Almc_PrecioVenta'] as num?)?.toDouble(),
      almcEstado: json['Almc_Estado'] is bool 
          ? (json['Almc_Estado'] as bool?) 
          : (json['Almc_Estado'] is int ? (json['Almc_Estado'] == 1) : null),

      nombreProducto: (json['NombreProducto'] as String?) ?? 'N/D', 
      detalleDescripcion: (json['Detalle_Descripcion'] as String?) ?? 'N/D', 
      detalleFechaVencimiento: json['Detalle_FechaVencimiento'] != null 
          ? DateTime.tryParse(json['Detalle_FechaVencimiento'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      if (almcId != null) 'Almc_Id': almcId,
      
      'Almc_Detalle_Id': almcDetalleId,
      'Almc_Proveedor_Id': almcProveedorId,
      'Almc_Lote': almcLote,
      'Almc_Existencia': almcExistencia,
      'Almc_PrecioCompra': almcPrecioCompra,
      'Almc_PrecioVenta': almcPrecioVenta,
      'Almc_Estado': almcEstado == true ? 1 : 0, 
    };
    
    return data;
  }
}