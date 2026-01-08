import 'package:autovitae/data/models/taller.dart';
import 'package:autovitae/data/repositories/taller_repository.dart';

class TallerViewModel {
  final TallerRepository _repository = TallerRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Taller> _talleres = [];
  List<Taller> get talleres => _talleres;

  String? _error;
  String? get error => _error;

  // Registrar taller
  Future<bool> registrarTaller(Taller taller) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.create(taller);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar todos los talleres
  Future<void> cargarTalleres() async {
    _isLoading = true;
    _error = null;
    try {
      _talleres = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
      _talleres = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar talleres activos
  Future<void> cargarTalleresActivos() async {
    _isLoading = true;
    _error = null;
    try {
      _talleres = await _repository.getActive();
    } catch (e) {
      _error = e.toString();
      _talleres = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar taller por ID
  Future<Taller?> cargarTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidTaller);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Buscar talleres por nombre
  Future<void> buscarPorNombre(String nombre) async {
    _isLoading = true;
    _error = null;
    try {
      final allTalleres = await _repository.getAll();
      _talleres = allTalleres
          .where((t) => t.nombre.toLowerCase().contains(nombre.toLowerCase()))
          .toList();
    } catch (e) {
      _error = e.toString();
      _talleres = [];
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar taller
  Future<bool> actualizarTaller(String uid, Taller taller) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, taller);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar taller (desactivar)
  Future<bool> eliminarTaller(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.delete(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Activar taller
  Future<bool> activarTaller(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.activate(uid);
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
