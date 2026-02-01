import 'dart:io';
import 'package:autovitae/data/models/cliente.dart';
import 'package:autovitae/data/models/usuario.dart';
import 'package:autovitae/data/models/rol_usuario.dart';
import 'package:autovitae/data/repositories/cliente_repository.dart';
import 'package:autovitae/data/repositories/usuario_repository.dart';
import 'package:autovitae/data/repositories/auth_repository.dart';
import 'package:autovitae/data/services/cloudinary_service.dart';
import 'package:autovitae/core/utils/extract_public_id_url.dart';
import 'package:autovitae/core/utils/session_manager.dart';

class ClienteViewModel {
  final ClienteRepository _clienteRepository = ClienteRepository();
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final AuthRepository _authRepository = AuthRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Cliente> _clientes = [];
  List<Cliente> get clientes => _clientes;

  String? _error;
  String? get error => _error;

  /// Reautenticar usuario con contraseña
  Future<bool> reauthenticate(String password) async {
    _error = null;
    try {
      await _authRepository.reauthenticate(password);
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    }
  }

  /// Actualizar perfil del cliente (usuario + cliente) con foto opcional
  Future<bool> actualizarPerfil({
    required String uidUsuario,
    required String uidCliente,
    required String nombre,
    required String apellido,
    required String telefono,
    required String direccion,
    required String ciudad,
    File? nuevaFoto,
    String? fotoUrlActual,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      String? fotoUrl = fotoUrlActual;

      // Subir nueva foto si se proporcionó
      if (nuevaFoto != null) {
        // Eliminar foto anterior si existe
        if (fotoUrlActual != null && fotoUrlActual.isNotEmpty) {
          final publicId = extractPublicIdFromUrl(fotoUrlActual);
          if (publicId.isNotEmpty) {
            try {
              await _cloudinaryService.removeImage(publicId);
            } catch (_) {
              // Ignorar error si no se puede eliminar
            }
          }
        }
        // Subir nueva foto
        fotoUrl = await _cloudinaryService.uploadImage(nuevaFoto);
      }

      // Obtener usuario actual para preservar campos que no se editan
      final usuarioActual = await _usuarioRepository.getById(uidUsuario);
      if (usuarioActual == null) {
        throw Exception('Usuario no encontrado');
      }

      // Actualizar usuario
      final usuarioActualizado = Usuario(
        uidUsuario: uidUsuario,
        nombre: nombre,
        apellido: apellido,
        cedula: usuarioActual.cedula,
        correo: usuarioActual.correo,
        telefono: telefono,
        fotoUrl: fotoUrl,
        rol: usuarioActual.rol,
        estado: usuarioActual.estado,
        fechaRegistro: usuarioActual.fechaRegistro,
      );

      await _usuarioRepository.update(uidUsuario, usuarioActualizado);

      // Obtener cliente actual
      final clienteActual = await _clienteRepository.getById(uidCliente);
      if (clienteActual == null) {
        throw Exception('Cliente no encontrado');
      }

      // Actualizar cliente
      final clienteActualizado = Cliente(
        uidCliente: uidCliente,
        uidUsuario: uidUsuario,
        direccion: direccion,
        ciudad: ciudad,
        estado: clienteActual.estado,
      );

      await _clienteRepository.update(uidCliente, clienteActualizado);

      // Actualizar sesión local
      await SessionManager().saveSession(
        usuario: usuarioActualizado,
        cliente: clienteActualizado,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  String _parseError(String error) {
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Contraseña incorrecta';
    }
    if (error.contains('too-many-requests')) {
      return 'Demasiados intentos. Intente más tarde';
    }
    return 'Error de autenticación';
  }

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
