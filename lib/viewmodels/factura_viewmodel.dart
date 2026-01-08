import 'package:autovitae/data/models/factura.dart';
import 'package:autovitae/data/models/factura_detalle.dart';
import 'package:autovitae/data/models/metodo_pago.dart';
import 'package:autovitae/data/repositories/factura_detalle_repository.dart';
import 'package:autovitae/data/repositories/factura_repository.dart';

class FacturaViewModel {
  final FacturaRepository _repository = FacturaRepository();
  final FacturaDetalleRepository _detalleRepository =
      FacturaDetalleRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Factura> _facturas = [];
  List<Factura> get facturas => _facturas;

  List<FacturaDetalle> _detalles = [];
  List<FacturaDetalle> get detalles => _detalles;

  String? _error;
  String? get error => _error;

  // Registrar factura
  Future<String?> registrarFactura(Factura factura) async {
    _isLoading = true;
    _error = null;
    try {
      final uid = await _repository.create(factura);
      return uid;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Crear factura con detalles
  Future<bool> crearFacturaConDetalles(
      Factura factura, List<FacturaDetalle> detalles) async {
    _isLoading = true;
    _error = null;
    try {
      final uidFactura = await _repository.create(factura);

      for (final detalle in detalles) {
        final detalleConFactura = FacturaDetalle(
          uidFactura: uidFactura,
          uidServicio: detalle.uidServicio,
          cantidad: detalle.cantidad,
          precioUnitario: detalle.precioUnitario,
          subtotal: detalle.subtotal,
        );
        await _detalleRepository.create(detalleConFactura);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Agregar detalle de factura
  Future<bool> agregarDetalle(FacturaDetalle detalle) async {
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

  // Cargar facturas por cliente
  Future<void> cargarFacturasPorCliente(String uidCliente) async {
    _isLoading = true;
    _error = null;
    try {
      _facturas = await _repository.getByClienteId(uidCliente);
    } catch (e) {
      _error = e.toString();
      _facturas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar facturas por mantenimiento
  Future<void> cargarFacturasPorMantenimiento(String uidMantenimiento) async {
    _isLoading = true;
    _error = null;
    try {
      final factura = await _repository.getByMantenimientoId(uidMantenimiento);
      _facturas = factura != null ? [factura] : [];
    } catch (e) {
      _error = e.toString();
      _facturas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar facturas por método de pago
  Future<void> cargarFacturasPorMetodoPago(MetodoPago metodoPago) async {
    _isLoading = true;
    _error = null;
    try {
      _facturas = await _repository.getByMetodoPago(metodoPago);
    } catch (e) {
      _error = e.toString();
      _facturas = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar detalles de factura
  Future<void> cargarDetallesFactura(String uidFactura) async {
    _isLoading = true;
    _error = null;
    try {
      _detalles = await _detalleRepository.getByFacturaId(uidFactura);
    } catch (e) {
      _error = e.toString();
      _detalles = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar factura por ID
  Future<Factura?> cargarFactura(String uidFactura) async {
    _isLoading = true;
    _error = null;
    try {
      return await _repository.getById(uidFactura);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Actualizar factura
  Future<bool> actualizarFactura(String uid, Factura factura) async {
    _isLoading = true;
    _error = null;
    try {
      await _repository.update(uid, factura);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Calcular subtotal
  double calcularSubtotal() {
    return _detalles.fold(0.0, (sum, detalle) => sum + detalle.subtotal);
  }

  // Calcular IVA
  double calcularIva(double porcentajeIva) {
    return calcularSubtotal() * (porcentajeIva / 100);
  }

  // Calcular total
  double calcularTotal(double porcentajeIva) {
    return calcularSubtotal() + calcularIva(porcentajeIva);
  }

  // Actualizar detalle de factura
  Future<bool> actualizarDetalle(String uid, FacturaDetalle detalle) async {
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

  // Eliminar detalle de factura
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

  // Eliminar factura
  Future<bool> eliminarFactura(String uid) async {
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
