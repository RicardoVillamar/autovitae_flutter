import 'package:autovitae/model/enums/rol_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String? uidUsuario;
  final String nombre;
  final String apellido;
  final String cedula;
  final String correo;
  final String telefono;
  final String? fotoUrl;
  final RolUsuario rol;
  final int estado;
  final Timestamp fechaRegistro;

  Usuario({
    this.uidUsuario,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.correo,
    required this.telefono,
    this.fotoUrl,
    this.rol = RolUsuario.cliente,
    this.estado = 1,
    Timestamp? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? Timestamp.now();

  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Usuario no encontrado');
    }
    return Usuario(
      uidUsuario: doc.id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      correo: data['correo'] ?? '',
      cedula: data['cedula'] ?? '',
      telefono: data['telefono'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      rol: RolUsuarioX.fromString(data['rol'] ?? 'cliente'),
      estado: (data['estado'] ?? 1) as int,
      fechaRegistro: data['fechaRegistro'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidUsuario': uidUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'correo': correo,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'rol': rol.value,
      'estado': estado,
      'fechaRegistro': fechaRegistro,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uidUsuario: map['uidUsuario'],
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      cedula: map['cedula'] ?? '',
      telefono: map['telefono'] ?? '',
      fotoUrl: map['fotoUrl'],
      rol: RolUsuarioX.fromString(map['rol'] ?? 'cliente'),
      estado: (map['estado'] ?? 1) as int,
      fechaRegistro: map['fechaRegistro'] is Timestamp
          ? map['fechaRegistro']
          : (map['fechaRegistro'] != null
                ? Timestamp.fromMillisecondsSinceEpoch(map['fechaRegistro'])
                : Timestamp.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uidUsuario': uidUsuario,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'correo': correo,
      'telefono': telefono,
      'fotoUrl': fotoUrl,
      'rol': rol.value,
      'estado': estado,
      'fechaRegistro': fechaRegistro.millisecondsSinceEpoch,
    };
  }
}
