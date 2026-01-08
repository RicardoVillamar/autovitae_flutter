enum RolUsuario { admin, cliente, gerente }

extension RolUsuarioX on RolUsuario {
  String get value => name;

  static RolUsuario fromString(String rol) {
    return RolUsuario.values.firstWhere(
      (e) => e.name == rol,
      orElse: () => RolUsuario.cliente,
    );
  }
}
