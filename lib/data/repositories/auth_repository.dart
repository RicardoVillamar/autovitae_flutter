import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/data/repositories/gerente_repository.dart';
import 'package:autovitae/core/utils/session_manager.dart';

// Resultado de autenticación con información completa
class AuthResult {
  final String uid;
  final RolUsuario rol;
  final Usuario usuario;
  final Cliente? cliente;
  final Gerente? gerente;
  final bool primerLoginGerente;

  AuthResult({
    required this.uid,
    required this.rol,
    required this.usuario,
    this.cliente,
    this.gerente,
    this.primerLoginGerente = false,
  });
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final ClienteRepository _clienteRepository = ClienteRepository();
  final GerenteRepository _gerenteRepository = GerenteRepository();
  final SessionManager _sessionManager = SessionManager();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar usuario con email y contraseña
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Iniciar sesión con email y contraseña y cargar datos completos
  Future<AuthResult> login({
    required String email,
    required String password,
    bool persistSession = true,
  }) async {
    try {
      // Autenticar usuario
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Obtener datos completos del usuario
      return await _loadUserData(uid, persistSession: persistSession);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Validar sesión activa
  Future<AuthResult> validateActiveSession() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No hay sesión activa');
      }

      final uid = currentUser.uid;

      // Verificar si existe en Firestore
      final usuarioDoc = await _firestore.collection('usuarios').doc(uid).get();

      if (!usuarioDoc.exists) {
        throw Exception('El usuario no tiene datos registrados');
      }

      // Cargar datos completos
      return await _loadUserData(uid);
    } catch (e) {
      throw Exception('Error al validar sesión: $e');
    }
  }

  // Cargar datos completos del usuario según su rol
  Future<AuthResult> _loadUserData(
    String uid, {
    bool persistSession = true,
  }) async {
    try {
      // Obtener usuario
      final usuario = await _usuarioRepository.getById(uid);

      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }

      // Verificar rol
      if (usuario.rol == RolUsuario.cliente) {
        // Intentar cargar datos del cliente desde colección separada
        final cliente = await _clienteRepository.getByUsuarioId(uid);

        // Si no existe el documento de cliente, devolver error para que se
        // corrijan los datos en Firestore (relación `uidUsuario` faltante).
        if (cliente == null) {
          throw Exception('Datos de cliente no encontrados en Firestore');
        }

        // Guardar sesión
        if (persistSession) {
          await _sessionManager.saveSession(usuario: usuario, cliente: cliente);
        }

        return AuthResult(
          uid: uid,
          rol: usuario.rol,
          usuario: usuario,
          cliente: cliente,
        );
      } else if (usuario.rol == RolUsuario.gerente) {
        // Intentar cargar datos del gerente desde colección separada
        final gerente = await _gerenteRepository.getByUsuarioId(uid);

        // Si no existe el documento de gerente, devolver error para que se
        // corrijan los datos en Firestore (relación `uidUsuario` faltante).
        if (gerente == null) {
          throw Exception('Datos de gerente no encontrados en Firestore');
        }

        // Guardar sesión
        if (persistSession) {
          await _sessionManager.saveSession(usuario: usuario, gerente: gerente);
        }

        // Verificar si es primer login
        final primerLogin = gerente.primerLogin;

        return AuthResult(
          uid: uid,
          rol: usuario.rol,
          usuario: usuario,
          gerente: gerente,
          primerLoginGerente: primerLogin,
        );
      } else if (usuario.rol == RolUsuario.admin) {
        // Guardar sesión del admin
        if (persistSession) {
          await _sessionManager.saveSession(usuario: usuario);
        }

        return AuthResult(uid: uid, rol: usuario.rol, usuario: usuario);
      } else {
        throw Exception('Rol de usuario no válido');
      }
    } catch (e) {
      throw Exception('Error al cargar datos del usuario: $e');
    }
  }

  // Verificar si es primer login del gerente
  Future<bool> isPrimerLoginGerente(String uid) async {
    try {
      final gerente = await _gerenteRepository.getByUsuarioId(uid);
      return gerente?.primerLogin ?? false;
    } catch (e) {
      return false;
    }
  }

  // Actualizar primer login del gerente
  Future<void> updatePrimerLoginGerente(String uid, bool primerLogin) async {
    try {
      final gerente = await _gerenteRepository.getByUsuarioId(uid);

      if (gerente != null && gerente.uidGerente != null) {
        await _gerenteRepository.updatePrimerLogin(
          gerente.uidGerente!,
          primerLogin,
        );

        // Actualizar en sesión
        final gerenteActualizado = Gerente(
          uidGerente: gerente.uidGerente,
          uidUsuario: gerente.uidUsuario,
          uidTaller: gerente.uidTaller,
          estado: gerente.estado,
          primerLogin: primerLogin,
          fechaAsignacion: gerente.fechaAsignacion,
        );

        await _sessionManager.updateGerente(gerenteActualizado);
      }
    } catch (e) {
      throw Exception('Error al actualizar primer login: $e');
    }
  }

  // Iniciar sesión simple (backward compatibility)
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      // Limpiar sesión
      await _sessionManager.removeSession();

      // Cerrar sesión en Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Error al enviar email de verificación: $e');
    }
  }

  // Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Reautenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  // Actualizar email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Reautenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Actualizar email
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al actualizar email: $e');
    }
  }

  // Eliminar cuenta
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Reautenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Eliminar usuario de Firestore
      final usuario = await _usuarioRepository.getByEmail(user.email!);
      if (usuario != null && usuario.uidUsuario != null) {
        await _usuarioRepository.delete(usuario.uidUsuario!);
      }

      // Eliminar cuenta de Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al eliminar cuenta: $e');
    }
  }

  // Reautenticar usuario
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al reautenticar: $e');
    }
  }

  // Verificar si el email está verificado
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Recargar usuario
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Error al recargar usuario: $e');
    }
  }

  // Obtener token de ID
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      throw Exception('Error al obtener token: $e');
    }
  }

  // Manejar excepciones de Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'requires-recent-login':
        return 'Requiere inicio de sesión reciente';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
