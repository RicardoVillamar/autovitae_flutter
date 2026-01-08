import 'package:cloud_firestore/cloud_firestore.dart';

class FacturaDetalle {
  final String? uidDetalle;
  final String uidFactura;
  final String uidServicio;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  FacturaDetalle({
    this.uidDetalle,
    required this.uidFactura,
    required this.uidServicio,
    this.cantidad = 1,
    this.precioUnitario = 0.0,
    this.subtotal = 0.0,
  });

  factory FacturaDetalle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('FacturaDetalle no encontrado');
    }
    return FacturaDetalle(
      uidDetalle: doc.id,
      uidFactura: data['uidFactura'] ?? '',
      uidServicio: data['uidServicio'] ?? '',
      cantidad: (data['cantidad'] ?? 1) as int,
      precioUnitario: (data['precioUnitario'] is num)
          ? (data['precioUnitario'] as num).toDouble()
          : double.tryParse((data['precioUnitario'] ?? 0).toString()) ?? 0.0,
      subtotal: (data['subtotal'] is num)
          ? (data['subtotal'] as num).toDouble()
          : double.tryParse((data['subtotal'] ?? 0).toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidDetalle': uidDetalle,
      'uidFactura': uidFactura,
      'uidServicio': uidServicio,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
