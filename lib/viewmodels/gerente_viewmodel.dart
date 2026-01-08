import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:autovitae/data/repositories/gerente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/core/utils/session_manager.dart';

class GerenteViewModel {
  final GerenteRepository _gerenteRepository = GerenteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Gerente> _gerentes = [];
  List<Gerente> get gerentes => _gerentes;

  String? _error;
  String? get error => _error;

  // Registrar gerente (Usuario + Gerente)
  Future<bool> registrarGerente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    try {
      // Crear usuario
      final usuario = Usuario(
        uidUsuario: null,
        cedula: cedula,
        nombre: nombres,
        apellido: apellidos,
        correo: email,
        telefono: telefono,
        rol: RolUsuario.gerente,
        estado: 1,
      );

      final uidUsuario = await _usuarioRepository.create(usuario);

      // Crear gerente sin taller asignado
      final gerente = Gerente(
        uidGerente: null,
        uidUsuario: uidUsuario,
        uidTaller: null,
        primerLogin: true,
        estado: 1,
      );

      await _gerenteRepository.create(gerente);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar todos los gerentes
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

  // Cargar gerentes activos
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

  // Cargar gerentes sin taller asignado
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

  // Cargar gerente por ID
  Future<Gerente?> cargarGerente(String uidGerente) async {
    _isLoading = true;
    _error = null;
    try {
      return await _gerenteRepository.getById(uidGerente);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar gerente por taller
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

  // Asignar taller a gerente
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
          fechaAsignacion: gerente.fechaAsignacion,
        );
        await _gerenteRepository.update(uidGerente, gerenteActualizado);
      }

      // Actualizar sesión si es el gerente logueado
      final session = await SessionManager().getSession();
      if (session['gerente']?['uidGerente'] == uidGerente) {
        final gerenteActualizado = await _gerenteRepository.getById(uidGerente);
        if (gerenteActualizado != null) {
          await SessionManager().updateSession(gerente: gerenteActualizado);
        }
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Remover taller de gerente
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
          fechaAsignacion: gerente.fechaAsignacion,
        );
        await _gerenteRepository.update(uidGerente, gerenteActualizado);
      }

      // Actualizar sesión si es el gerente logueado
      final session = await SessionManager().getSession();
      if (session['gerente']?['uidGerente'] == uidGerente) {
        final gerenteActualizado = await _gerenteRepository.getById(uidGerente);
        if (gerenteActualizado != null) {
          await SessionManager().updateSession(gerente: gerenteActualizado);
        }
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar gerente
  Future<bool> actualizarGerente(String uid, Gerente gerente) async {
    _isLoading = true;
    _error = null;
    try {
      await _gerenteRepository.update(uid, gerente);

      // Actualizar sesión si es el gerente logueado
      final session = await SessionManager().getSession();
      if (session['gerente']?['uid'] == uid) {
        await SessionManager().updateSession(gerente: gerente);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar gerente (desactivar)
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

  // Activar gerente
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

  void clearError() {
    _error = null;
  }
}
