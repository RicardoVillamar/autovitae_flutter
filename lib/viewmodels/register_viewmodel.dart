import 'package:autovitae/data/repositories/auth_repository.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> registerCliente({
    required String nombre,
    required String apellido,
    required String cedula,
    required String email,
    required String password,
    required String telefono,
    required String direccion,
    required String ciudad,
    String? fotoUrl,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      // 1. Crear usuario en Firebase Auth
      final userCredential = await _authRepository.registerWithEmailPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al crear usuario de autenticación');
      }

      final uid = userCredential.user!.uid;

      // 2. Crear documento de Usuario en Firestore con el mismo ID
      final usuario = Usuario(
        uidUsuario: uid,
        nombre: nombre,
        apellido: apellido,
        cedula: cedula,
        correo: email,
        telefono: telefono,
        fotoUrl: fotoUrl,
        rol: RolUsuario.cliente,
        estado: 1,
      );

      await _firestore.collection('usuarios').doc(uid).set(usuario.toFirestore());

      // 3. Crear documento de Cliente en Firestore
      // El cliente referencia al usuario. El ID del documento cliente puede ser aleatorio.
      final cliente = Cliente(
        uidUsuario: uid,
        direccion: direccion,
        ciudad: ciudad,
        estado: 1,
      );

      await _firestore.collection('clientes').add(cliente.toFirestore());

      // 4. Iniciar sesión automáticamente (opcional, pero AuthRepo login lo hace completo)
      // Como ya está autenticado en Auth, solo necesitamos cargar los datos en sesión si queremos
      // redirigir al Home inmediatamente sin pedir login de nuevo.
      // El register de Auth loguea automáticamente.
      // Pero AuthRepository.login hace el fetch de datos.
      
      // Llamamos a login para guardar la sesión correctamente
      await _authRepository.login(email: email, password: password);

      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }
}