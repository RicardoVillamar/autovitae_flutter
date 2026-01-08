import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';

class ServicioTaller {
  final String? uidServicio;
  final String uidTaller;
  final String nombre;
  final String? descripcion;
  final double precio;
  final CategoriaSerivicioTaller categoria;
  final int estado;

  ServicioTaller({
    this.uidServicio,
    required this.uidTaller,
    required this.nombre,
    this.descripcion,
    this.precio = 0.0,
    this.categoria = CategoriaSerivicioTaller.otros,
    this.estado = 1,
  });

  factory ServicioTaller.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('ServicioTaller no encontrado');
    }
    return ServicioTaller(
      uidServicio: doc.id,
      uidTaller: data['uidTaller'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] is num)
          ? (data['precio'] as num).toDouble()
          : double.tryParse((data['precio'] ?? 0).toString()) ?? 0.0,
      categoria: CategoriaSerivicioTallerX.fromString(
        data['categoria'] ?? 'otros',
      ),
      estado: (data['estado'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidServicio': uidServicio,
      'uidTaller': uidTaller,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria.value,
      'estado': estado,
    };
  }
}
