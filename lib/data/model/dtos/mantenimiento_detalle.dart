import 'package:cloud_firestore/cloud_firestore.dart';

class MantenimientoDetalle {
  final String? uidDetalle;
  final String uidMantenimiento;
  final String uidServicio;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  MantenimientoDetalle({
    this.uidDetalle,
    required this.uidMantenimiento,
    required this.uidServicio,
    this.cantidad = 1,
    this.precioUnitario = 0.0,
    this.subtotal = 0.0,
  });

  factory MantenimientoDetalle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('MantenimientoDetalle no encontrado');
    }
    return MantenimientoDetalle(
      uidDetalle: doc.id,
      uidMantenimiento: data['uidMantenimiento'] ?? '',
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
      'uidMantenimiento': uidMantenimiento,
      'uidServicio': uidServicio,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
