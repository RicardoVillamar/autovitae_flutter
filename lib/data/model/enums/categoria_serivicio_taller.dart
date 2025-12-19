enum CategoriaSerivicioTaller {
  mecanica,
  limpieza,
  pulido,
  remolque,
  cambioLlantas,
  otros,
}

extension CategoriaSerivicioTallerX on CategoriaSerivicioTaller {
  String get value => name;

  static CategoriaSerivicioTaller fromString(String value) {
    return CategoriaSerivicioTaller.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CategoriaSerivicioTaller.otros,
    );
  }
}
