import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/model/enums/metodo_pago.dart';
import 'package:autovitae/model/enums/estado_factura.dart';

class Factura {
  final String? uidFactura;
  final String uidMantenimiento;
  final String uidCliente;
  final Timestamp fechaEmision;
  final double subtotal;
  final double iva;
  final double total;
  final MetodoPago metodoPago;
  final EstadoFactura estado;

  Factura({
    this.uidFactura,
    required this.uidMantenimiento,
    required this.uidCliente,
    Timestamp? fechaEmision,
    this.subtotal = 0.0,
    this.iva = 0.0,
    this.total = 0.0,
    this.metodoPago = MetodoPago.efectivo,
    this.estado = EstadoFactura.pendiente,
  }) : fechaEmision = fechaEmision ?? Timestamp.now();

  factory Factura.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Factura no encontrada');
    }
    return Factura(
      uidFactura: doc.id,
      uidMantenimiento: data['uidMantenimiento'] ?? '',
      uidCliente: data['uidCliente'] ?? '',
      fechaEmision: data['fechaEmision'] ?? Timestamp.now(),
      subtotal: (data['subtotal'] is num)
          ? (data['subtotal'] as num).toDouble()
          : double.tryParse((data['subtotal'] ?? 0).toString()) ?? 0.0,
      iva: (data['iva'] is num)
          ? (data['iva'] as num).toDouble()
          : double.tryParse((data['iva'] ?? 0).toString()) ?? 0.0,
      total: (data['total'] is num)
          ? (data['total'] as num).toDouble()
          : double.tryParse((data['total'] ?? 0).toString()) ?? 0.0,
      metodoPago: MetodoPagoX.fromString(data['metodoPago'] ?? 'efectivo'),
      estado: EstadoFacturaX.fromString(data['estado'] ?? 'pendiente'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidFactura': uidFactura,
      'uidMantenimiento': uidMantenimiento,
      'uidCliente': uidCliente,
      'fechaEmision': fechaEmision,
      'subtotal': subtotal,
      'iva': iva,
      'total': total,
      'metodoPago': metodoPago.value,
      'estado': estado.value,
    };
  }
}
