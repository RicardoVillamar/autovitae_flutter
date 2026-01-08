import 'package:autovitae/data/models/mantenimiento.dart';
import 'package:autovitae/data/models/mantenimiento_detalle.dart';
import 'package:autovitae/data/models/estado_mantenimiento.dart';
import 'package:autovitae/data/repositories/mantenimiento_detalle_repository.dart';
import 'package:autovitae/data/repositories/mantenimiento_repository.dart';

class MantenimientoViewModel {
  final MantenimientoRepository _repository = MantenimientoRepository();
  final MantenimientoDetalleRepository _detalleRepository =
      MantenimientoDetalleRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Mantenimiento> _mantenimientos = [];
  List<Mantenimiento> get mantenimientos => _mantenimientos;

  List<MantenimientoDetalle> _detalles = [];
  List<MantenimientoDetalle> get detalles => _detalles;

  String? _error;
  String? get error => _error;

  // Registrar mantenimiento
  Future<String?> registrarMantenimiento(Mantenimiento mantenimiento) async {
    _isLoading = true;
    _error = null;
    try {
      final uid = await _repository.create(mantenimiento);
      return uid;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Registrar mantenimiento con detalles
  Future<bool> registrarMantenimientoConDetalles(
    Mantenimiento mantenimiento,
    List<String> serviciosIds,
    List<double> precios,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      final uidMantenimiento = await _repository.create(mantenimiento);
      
      for (int i = 0; i < serviciosIds.length; i++) {
        final detalle = MantenimientoDetalle(
          uidDetalle: null,
          uidMantenimiento: uidMantenimiento,
          uidServicio: serviciosIds[i],
          cantidad: 1,
          precioUnitario: precios[i],
          subtotal: precios[i],
        );
        await _detalleRepository.create(detalle);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Agregar detalle de mantenimiento
  Future<bool> agregarDetalle(MantenimientoDetalle detalle) async {
    _isLoading = true;
    _error = null;
    try {
      await _detalleRepository.create(detalle);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar mantenimientos por taller
  Future<void> cargarMantenimientosPorTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      _mantenimientos = await _repository.getByTallerId(uidTaller);
    } catch (e) {
      _error = e.toString();
      _mantenimientos = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar mantenimientos por vehículo
  Future<void> cargarMantenimientosPorVehiculo(String uidVehiculo) async {
    _isLoading = true;
    _error = null;
    try {
      final allMantenimientos = await _repository.getAll();
      // Need to filter by cita's vehicle
      _mantenimientos = allMantenimientos;
    } catch (e) {
      _error = e.toString();
      _mantenimientos = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar mantenimientos por estado
  Future<void> cargarMantenimientosPorEstado(EstadoMantenimiento estado) async {
    _isLoading = true;
    _error = null;
    try {
      _mantenimientos = await _repository.getByEstado(estado);
    } catch (e) {
      _error = e.toString();
      _mantenimientos = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar mantenimientos por taller y estado
  Future<void> cargarMantenimientosPorTallerYEstado(
    String uidTaller,
    EstadoMantenimiento estado,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      _mantenimientos = await _repository.getByTallerAndEstado(
        uidTaller,
        estado,
      );
    } catch (e) {
      _error = e.toString();
      _mantenimientos = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar detalles de mantenimiento
  Future<void> cargarDetallesMantenimiento(String uidMantenimiento) async {
    _isLoading = true;
    _error = null;
    try {
      _detalles = await _detalleRepository.getByMantenimientoId(
        uidMantenimiento,
      );
    } catch (e) {
      _error = e.toString();
      _detalles = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar mantenimiento por ID
  Future<Mantenimiento?> cargarMantenimiento(String uidMantenimiento) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidMantenimiento);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar mantenimiento
  Future<bool> actualizarMantenimiento(
    String uid,
    Mantenimiento mantenimiento,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, mantenimiento);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar estado de mantenimiento
  Future<bool> actualizarEstadoMantenimiento(
    String uid,
    EstadoMantenimiento estado,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.updateEstado(uid, estado);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Calcular total de mantenimiento
  double calcularTotal() {
    return _detalles.fold(
      0.0,
      (sum, detalle) => sum + (detalle.precioUnitario * detalle.cantidad),
    );
  }

  // Actualizar detalle de mantenimiento
  Future<bool> actualizarDetalle(
    String uid,
    MantenimientoDetalle detalle,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      await _detalleRepository.update(uid, detalle);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar detalle de mantenimiento
  Future<bool> eliminarDetalle(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _detalleRepository.delete(uid);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar mantenimiento
  Future<bool> eliminarMantenimiento(String uid) async {
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

  void clearError() {
    _error = null;
  }
}
