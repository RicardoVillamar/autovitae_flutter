import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autovitae/model/dtos/usuario.dart';
import 'package:autovitae/model/dtos/cliente.dart';
import 'package:autovitae/model/dtos/gerente.dart';
import 'package:autovitae/model/enums/rol_usuario.dart';

class SessionManager {
  static const String _keyUsuario = 'usuario';
  static const String _keyCliente = 'cliente';
  static const String _keyGerente = 'gerente';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  // Singleton
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  // Guardar sesión de usuario
  Future<void> saveSession({
    required Usuario usuario,
    Cliente? cliente,
    Gerente? gerente,
  }) async {
    await init();

    // Guardar usuario
    await _prefs?.setString(_keyUsuario, jsonEncode(usuario.toJson()));

    // Guardar según rol
    if (usuario.rol == RolUsuario.cliente && cliente != null) {
      await _prefs?.setString(_keyCliente, jsonEncode(cliente.toFirestore()));
    } else if (usuario.rol == RolUsuario.gerente && gerente != null) {
      await _prefs?.setString(_keyGerente, jsonEncode(gerente.toFirestore()));
    }

    // Marcar como logueado
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }

  // Obtener usuario de la sesión
  Future<Usuario?> getUsuario() async {
    await init();
    final usuarioJson = _prefs?.getString(_keyUsuario);
    if (usuarioJson != null) {
      try {
        return Usuario.fromMap(jsonDecode(usuarioJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Obtener cliente de la sesión
  Future<Cliente?> getCliente() async {
    await init();
    final clienteJson = _prefs?.getString(_keyCliente);
    if (clienteJson != null) {
      try {
        final map = jsonDecode(clienteJson) as Map<String, dynamic>;
        return Cliente(
          uidCliente: map['uidCliente'],
          uidUsuario: map['uidUsuario'],
          direccion: map['direccion'] ?? '',
          ciudad: map['ciudad'] ?? '',
          estado: map['estado'] ?? 1,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Obtener gerente de la sesión
  Future<Gerente?> getGerente() async {
    await init();
    final gerenteJson = _prefs?.getString(_keyGerente);
    if (gerenteJson != null) {
      try {
        final map = jsonDecode(gerenteJson) as Map<String, dynamic>;
        return Gerente(
          uidGerente: map['uidGerente'],
          uidUsuario: map['uidUsuario'],
          uidTaller: map['uidTaller'],
          estado: map['estado'] ?? 1,
          primerLogin: map['primerLogin'] ?? true,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Obtener rol del usuario
  Future<RolUsuario?> getRol() async {
    final usuario = await getUsuario();
    return usuario?.rol;
  }

  // Actualizar usuario en la sesión
  Future<void> updateUsuario(Usuario usuario) async {
    await init();
    await _prefs?.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  // Actualizar cliente en la sesión
  Future<void> updateCliente(Cliente cliente) async {
    await init();
    await _prefs?.setString(_keyCliente, jsonEncode(cliente.toFirestore()));
  }

  // Actualizar gerente en la sesión
  Future<void> updateGerente(Gerente gerente) async {
    await init();
    await _prefs?.setString(_keyGerente, jsonEncode(gerente.toFirestore()));
  }

  // Actualizar sesión completa
  Future<void> updateSession({
    Usuario? usuario,
    Cliente? cliente,
    Gerente? gerente,
  }) async {
    await init();

    if (usuario != null) {
      await updateUsuario(usuario);
    }

    if (cliente != null) {
      await updateCliente(cliente);
    }

    if (gerente != null) {
      await updateGerente(gerente);
    }
  }

  // Eliminar sesión
  Future<void> removeSession() async {
    await init();
    await _prefs?.remove(_keyUsuario);
    await _prefs?.remove(_keyCliente);
    await _prefs?.remove(_keyGerente);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }

  // Limpiar todos los datos
  Future<void> clearAll() async {
    await init();
    await _prefs?.clear();
  }

  // Obtener toda la sesión
  Future<Map<String, dynamic>> getSession() async {
    await init();

    final usuario = await getUsuario();
    final cliente = await getCliente();
    final gerente = await getGerente();
    final isLoggedIn = await this.isLoggedIn();

    return {
      'usuario': usuario,
      'cliente': cliente,
      'gerente': gerente,
      'isLoggedIn': isLoggedIn,
      'rol': usuario?.rol,
    };
  }

  // Verificar si es primera vez que inicia sesión (para gerentes)
  Future<bool> isPrimerLogin() async {
    final gerente = await getGerente();
    return gerente?.primerLogin ?? false;
  }

  // Actualizar primer login del gerente
  Future<void> updatePrimerLogin(bool primerLogin) async {
    final gerente = await getGerente();
    if (gerente != null) {
      final gerenteActualizado = Gerente(
        uidGerente: gerente.uidGerente,
        uidUsuario: gerente.uidUsuario,
        uidTaller: gerente.uidTaller,
        estado: gerente.estado,
        primerLogin: primerLogin,
        fechaAsignacion: gerente.fechaAsignacion,
      );
      await updateGerente(gerenteActualizado);
    }
  }
}
