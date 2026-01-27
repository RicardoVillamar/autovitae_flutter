import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:autovitae/data/repositories/gerente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/auth_repository.dart';
import 'package:autovitae/core/utils/session_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerenteViewModel {
  final GerenteRepository _gerenteRepository = GerenteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Gerente> _gerentes = [];
  List<Gerente> get gerentes => _gerentes;

  String? _error;
  String? get error => _error;

  Future<bool> registrarGerente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String password,
    String? fotoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    try {
      final authResult = await _authRepository.registerWithEmailPassword(
        email: email,
        password: password,
      );

      final String uidUsuario = authResult.user!.uid;

      final usuario = Usuario(
        uidUsuario: uidUsuario,
        cedula: cedula,
        nombre: nombres,
        apellido: apellidos,
        correo: email,
        telefono: telefono,
        rol: RolUsuario.gerente,
        estado: 1,
        fotoUrl: fotoUrl, 
      );

      await _firestore
          .collection('usuarios')
          .doc(uidUsuario)
          .set(usuario.toFirestore());

      final gerente = Gerente(
        uidGerente: uidUsuario, 
        uidUsuario: uidUsuario,
        uidTaller: null,
        primerLogin: true,
        estado: 1,
        fechaAsignacion: DateTime.now().millisecondsSinceEpoch,
      );

      await _firestore
          .collection('gerente') 
          .doc(uidUsuario)
          .set(gerente.toFirestore());

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // --- MÉTODOS DE CARGA ---

  Future<void> cargarGerentes() async {
    _isLoading = true;
    _error = null;
    try {
      _gerentes = await _gerenteRepository.getAll();
    } catch (e) {
      _error = e.toString();
      _gerentes = [];
    } finally {
      _isLoading = false;
    }
  }

  Future<void> cargarGerentesActivos() async {
    _isLoading = true;
    _error = null;
    try {
      final allGerentes = await _gerenteRepository.getAll();
      _gerentes = allGerentes.where((g) => g.estado == 1).toList();
    } catch (e) {
      _error = e.toString();
      _gerentes = [];
    } finally {
      _isLoading = false;
    }
  }

  Future<Gerente?> cargarGerentePorTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      return await _gerenteRepository.getByTallerId(uidTaller);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> cargarGerentesSinTaller() async {
    _isLoading = true;
    _error = null;
    try {
      final allGerentes = await _gerenteRepository.getAll();
      _gerentes = allGerentes
          .where((g) => g.uidTaller == null && g.estado == 1)
          .toList();
    } catch (e) {
      _error = e.toString();
      _gerentes = [];
    } finally {
      _isLoading = false;
    }
  }

  // --- TALLERES ---

  Future<bool> asignarTaller(String uidGerente, String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      final gerente = await _gerenteRepository.getById(uidGerente);
      if (gerente != null) {
        final gerenteActualizado = Gerente(
          uidGerente: gerente.uidGerente,
          uidUsuario: gerente.uidUsuario,
          uidTaller: uidTaller,
          estado: gerente.estado,
          primerLogin: gerente.primerLogin,
          fechaAsignacion: DateTime.now().millisecondsSinceEpoch,
        );
        await _gerenteRepository.update(uidGerente, gerenteActualizado);
        await _updateLocalSession(uidGerente);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> removerTaller(String uidGerente) async {
    _isLoading = true;
    _error = null;
    try {
      final gerente = await _gerenteRepository.getById(uidGerente);
      if (gerente != null) {
        final gerenteActualizado = Gerente(
          uidGerente: gerente.uidGerente,
          uidUsuario: gerente.uidUsuario,
          uidTaller: null,
          estado: gerente.estado,
          primerLogin: gerente.primerLogin,
          fechaAsignacion: null,
        );
        await _gerenteRepository.update(uidGerente, gerenteActualizado);
        await _updateLocalSession(uidGerente);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // CRUD 
  Future<bool> actualizarGerente(String uid, Gerente gerente) async {
    _isLoading = true;
    _error = null;
    try {
      await _gerenteRepository.update(uid, gerente);
      await _updateLocalSession(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> eliminarGerente(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _gerenteRepository.delete(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> activarGerente(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _gerenteRepository.activate(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // --- UTILIDADES ---

  Future<void> _updateLocalSession(String uidGerente) async {
    final session = await SessionManager().getSession();
    if (session['gerente'] != null && session['gerente']['uidGerente'] == uidGerente) {
      final updatedData = await _gerenteRepository.getById(uidGerente);
      if (updatedData != null) {
        await SessionManager().updateSession(gerente: updatedData);
      }
    }
  }

  Future<bool> actualizarPerfilCompleto({
    required String uidUsuario,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    String? fotoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    try {
      await _firestore.collection('usuarios').doc(uidUsuario).update({
        'nombre': nombres,
        'apellido': apellidos,
        'correo': email,
        'telefono': telefono,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void clearError() => _error = null;
}