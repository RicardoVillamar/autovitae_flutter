enum EstadoMantenimiento { enProceso, finalizado, cancelado }

extension EstadoMantenimientoX on EstadoMantenimiento {
  String get value => name;

  static EstadoMantenimiento fromString(String value) {
    return EstadoMantenimiento.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoMantenimiento.enProceso,
    );
  }
}
