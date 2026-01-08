import 'package:autovitae/data/models/cita.dart';
import 'package:autovitae/data/models/estado_cita.dart';
import 'package:autovitae/data/repositories/cita_repository.dart';

class CitaViewModel {
  final CitaRepository _repository = CitaRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Cita> _citas = [];
  List<Cita> get citas => _citas;

  String? _error;
  String? get error => _error;

  // Registrar cita
  Future<bool> registrarCita(Cita cita) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.create(cita);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Cargar citas por cliente
  Future<void> cargarCitasPorCliente(String uidCliente) async {
    _isLoading = true;
    _error = null;
    try {
      _citas = await _repository.getByClienteId(uidCliente);
    } catch (e) {
      _error = e.toString();
      _citas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar citas por taller
  Future<void> cargarCitasPorTaller(String uidTaller) async {
    _isLoading = true;
    _error = null;
    try {
      _citas = await _repository.getByTallerId(uidTaller);
    } catch (e) {
      _error = e.toString();
      _citas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar citas por estado
  Future<void> cargarCitasPorEstado(EstadoCita estado) async {
    _isLoading = true;
    _error = null;
    try {
      _citas = await _repository.getByEstado(estado);
    } catch (e) {
      _error = e.toString();
      _citas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar citas por taller y estado
  Future<void> cargarCitasPorTallerYEstado(
    String uidTaller,
    EstadoCita estado,
  ) async {
    _isLoading = true;
    _error = null;
    try {
      _citas = await _repository.getByTallerAndEstado(uidTaller, estado);
    } catch (e) {
      _error = e.toString();
      _citas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar cita por ID
  Future<Cita?> cargarCita(String uidCita) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidCita);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar cita
  Future<bool> actualizarCita(String uid, Cita cita) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, cita);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar estado de cita
  Future<bool> actualizarEstadoCita(String uid, EstadoCita estado) async {
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

  // Cancelar cita
  Future<bool> cancelarCita(String uid) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.updateEstado(uid, EstadoCita.rechazada);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Eliminar cita
  Future<bool> eliminarCita(String uid) async {
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
