enum EstadoFactura { pagada, pendiente, anulado }

extension EstadoFacturaX on EstadoFactura {
  String get value => name;

  static EstadoFactura fromString(String value) {
    return EstadoFactura.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoFactura.pendiente,
    );
  }
}
