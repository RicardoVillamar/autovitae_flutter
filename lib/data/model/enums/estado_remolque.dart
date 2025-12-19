enum EstadoRemolque { pendiente, enCamino, completado, cancelado }

extension EstadoRemolqueX on EstadoRemolque {
  String get value => name;

  static EstadoRemolque fromString(String value) {
    return EstadoRemolque.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoRemolque.pendiente,
    );
  }
}
