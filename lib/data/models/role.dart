/// Enum de roles de la aplicación; se usa para autorización y lógica de UI.
enum Role {
  admin,
  vendedor,
  unknown,
}

Role roleFromId(int id) {
  switch (id) {
    case 1:
      return Role.admin;
    case 2:
      return Role.vendedor;
    default:
      return Role.unknown;
  }
}

int roleId(Role role) {
  switch (role) {
    case Role.admin:
      return 1;
    case Role.vendedor:
      return 2;
    case Role.unknown:
      return 0;
  }
}

extension RoleX on Role {
  bool get isAdmin => this == Role.admin;
  bool get isVendedor => this == Role.vendedor;
  String get displayName {
    switch (this) {
      case Role.admin:
        return 'Administrador';
      case Role.vendedor:
        return 'Vendedor';
      case Role.unknown:
        return 'Desconocido';
    }
  }
}
