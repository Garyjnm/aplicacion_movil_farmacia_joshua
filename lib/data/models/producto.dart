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
      almcId: json['almc_Id'] as int?,
      almcDetalleId: json['almc_Detalle_Id'] as int?,
      almcProveedorId: json['Almc_Proveedor_Id'] as int?,
      almcLote: (json['almc_Lote'] as String?) ?? '',
      almcExistencia: json['almc_Existencia'] as int?,
      almcPrecioCompra: (json['almc_PrecioCompra'] as num?)?.toDouble(),
      almcPrecioVenta: (json['almc_PrecioVenta'] as num?)?.toDouble(),
      almcEstado: json['almc_Estado'] is bool 
          ? (json['almc_Estado'] as bool?) 
          : (json['Almc_Estado'] is int ? (json['Almc_Estado'] == 1) : null),

      nombreProducto: (json['nombreProducto'] as String?) ?? 'N/D', 
      detalleDescripcion: (json['detalle_Descripcion'] as String?) ?? 'N/D', 
      detalleFechaVencimiento: json['detalle_FechaVencimiento'] != null
          ? DateTime.tryParse(json['detalle_FechaVencimiento'].toString()) 
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