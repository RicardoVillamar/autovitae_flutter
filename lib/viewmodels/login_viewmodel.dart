import 'package:autovitae/data/repositories/auth_repository.dart';
import 'package:autovitae/data/models/gerente.dart';
import 'package:autovitae/core/utils/session_manager.dart';

class LoginPageModel {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Login del usuario
  Future<AuthResult?> login(
    String email,
    String password, {
    bool persistSession = true,
  }) async {
    _isLoading = true;
    _error = null;
    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
        persistSession: persistSession,
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Validar sesión activa
  Future<AuthResult?> validateActiveSession() async {
    _isLoading = true;
    _error = null;
    try {
      return await _authRepository.validateActiveSession();
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  // Enviar email de recuperación
  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _error = null;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Verificar si es primer login del gerente
  Future<bool?> isPrimerLoginGerente() async {
    try {
      final session = await SessionManager().getSession();
      final gerente = session['gerente'] as Gerente?;
      return gerente?.primerLogin;
    } catch (e) {
      return null;
    }
  }

  // Actualizar primer login del gerente
  Future<bool> updatePrimerLoginGerente() async {
    _error = null;
    try {
      final session = await SessionManager().getSession();
      final gerente = session['gerente'] as Gerente?;
      if (gerente?.uidGerente != null) {
        await _authRepository.updatePrimerLoginGerente(
          gerente!.uidGerente!,
          false,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}
