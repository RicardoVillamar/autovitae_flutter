import 'package:autovitae/data/models/servicio_taller.dart';
import 'package:autovitae/data/models/categoria_serivicio_taller.dart';
import 'package:autovitae/data/repositories/servicio_taller_repository.dart';

class ServicioTallerViewModel {
  final ServicioTallerRepository _repository = ServicioTallerRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ServicioTaller> _servicios = [];
  List<ServicioTaller> get servicios => _servicios;

  String? _error;
  String? get error => _error;

  // Registrar servicio
  Future<bool> registrarServicio(ServicioTaller servicio) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.create(servicio);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar servicios por taller
  Future<void> cargarServiciosPorTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      _servicios = await _repository.getByTallerId(uidTaller);
    } catch (e) {
      _error = e.toString();
      _servicios = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar servicios activos por taller
  Future<void> cargarServiciosActivosPorTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      _servicios = await _repository.getActiveByTallerId(uidTaller);
    } catch (e) {
      _error = e.toString();
      _servicios = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar servicio por ID
  Future<ServicioTaller?> cargarServicio(String uidServicio) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidServicio);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar servicio
  Future<bool> actualizarServicio(String uid, ServicioTaller servicio) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, servicio);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar servicio
  Future<bool> eliminarServicio(String uid) async {
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

  // Activar servicio
  Future<bool> activarServicio(String uid) async {
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

  // Filtrar por categoría
  Future<void> filtrarPorCategoria(CategoriaSerivicioTaller categoria) async {
    _isLoading = true;
    _error = null;
    try {
      _servicios = await _repository.getByCategoria(categoria);
    } catch (e) {
      _error = e.toString();
      _servicios = [];
    } finally {
      _isLoading = false;
    }
  }

  void clearError() {
    _error = null;
  }
}
