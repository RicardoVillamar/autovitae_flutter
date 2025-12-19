enum EstadoCita { pendiente, confirmada, rechazada }

extension EstadoCitaX on EstadoCita {
  String get value => name;

  static EstadoCita fromString(String value) {
    return EstadoCita.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoCita.pendiente,
    );
  }
}
