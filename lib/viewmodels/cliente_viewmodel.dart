import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/core/utils/session_manager.dart';

class ClienteViewModel {
  final ClienteRepository _clienteRepository = ClienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Cliente> _clientes = [];
  List<Cliente> get clientes => _clientes;

  String? _error;
  String? get error => _error;

  // Registrar cliente (Usuario + Cliente)
  Future<bool> registrarCliente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String password,
    String? direccion,
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
        rol: RolUsuario.cliente,
        estado: 1,
      );

      final uidUsuario = await _usuarioRepository.create(usuario);

      // Crear cliente
      final cliente = Cliente(
        uidCliente: null,
        uidUsuario: uidUsuario,
        direccion: direccion ?? '',
        ciudad: '',
        estado: 1,
      );

      await _clienteRepository.create(cliente);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar todos los clientes
  Future<void> cargarClientes() async {
    _isLoading = true;
    _error = null;
    try {
      _clientes = await _clienteRepository.getAll();
    } catch (e) {
      _error = e.toString();
      _clientes = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar clientes activos
  Future<void> cargarClientesActivos() async {
    _isLoading = true;
    _error = null;
    try {
      final allClientes = await _clienteRepository.getAll();
      _clientes = allClientes.where((c) => c.estado == 1).toList();
    } catch (e) {
      _error = e.toString();
      _clientes = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar cliente por ID
  Future<Cliente?> cargarCliente(String uidCliente) async {
    _isLoading = true;
    _error = null;
    try {
      return await _clienteRepository.getById(uidCliente);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar cliente
  Future<bool> actualizarCliente(String uid, Cliente cliente) async {
    _isLoading = true;
    _error = null;
    try {
      await _clienteRepository.update(uid, cliente);

      // Actualizar sesión si es el cliente logueado
      final session = await SessionManager().getSession();
      if (session['cliente']?['uid'] == uid) {
        await SessionManager().updateSession(cliente: cliente);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar cliente (desactivar)
  Future<bool> eliminarCliente(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _clienteRepository.delete(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Activar cliente
  Future<bool> activarCliente(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _clienteRepository.activate(uid);
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
