enum MetodoPago { efectivo, tarjeta, transferencia }

extension MetodoPagoX on MetodoPago {
  String get value => name;

  static MetodoPago fromString(String value) {
    return MetodoPago.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MetodoPago.efectivo,
    );
  }
}
