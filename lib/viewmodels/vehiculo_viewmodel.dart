import 'package:autovitae/data/models/vehiculo.dart';
import 'package:autovitae/data/repositories/vehiculo_repository.dart';

class VehiculoViewModel {
  final VehiculoRepository _repository = VehiculoRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Vehiculo> _vehiculos = [];
  List<Vehiculo> get vehiculos => _vehiculos;

  String? _error;
  String? get error => _error;

  // Registrar vehículo
  Future<bool> registrarVehiculo(Vehiculo vehiculo) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.create(vehiculo);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar vehículos por cliente
  Future<void> cargarVehiculosPorCliente(String uidCliente) async {
    _isLoading = true;
    _error = null;
    try {
      _vehiculos = await _repository.getByClienteId(uidCliente);
    } catch (e) {
      _error = e.toString();
      _vehiculos = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar vehículo por ID
  Future<Vehiculo?> cargarVehiculo(String uidVehiculo) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidVehiculo);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar vehículo
  Future<bool> actualizarVehiculo(String uid, Vehiculo vehiculo) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, vehiculo);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar vehículo
  Future<bool> eliminarVehiculo(String uid) async {
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

  // Actualizar kilometraje
  Future<bool> actualizarKilometraje(String uid, int kilometraje) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.updateKilometraje(uid, kilometraje);
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
