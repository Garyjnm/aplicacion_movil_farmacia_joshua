import 'package:flutter/material.dart';
import '../../../data/models/roles.dart';
import '../../../data/services/roles_services.dart';
import '../../core/widgets/paginacion_controls.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_dialog.dart';

class RolesScreens extends StatefulWidget {
  const RolesScreens({Key? key}) : super(key: key);

  @override
  State<RolesScreens> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreens> {
  final RolesServices _service = RolesServices();
  late Future<List<Roles>> _futureRoles;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  List<Roles> _allRoles = [];
  List<Roles> _filteredRoles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _searchController.addListener(_filterRoles);
  }

  void _loadRoles() {
    _futureRoles = _service.getRol();
    _futureRoles.then((data) {
      _allRoles = data;
      _filteredRoles = List.from(_allRoles);
      setState(() {});
    });
  }

  void _refresh() {
    _loadRoles();
  }

  void _filterRoles() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredRoles = List.from(_allRoles);
    } else {
      _filteredRoles = _allRoles
          .where(
            (cat) =>
                cat.nombre.toLowerCase().contains(query) ||
                cat.descripcion.toLowerCase().contains(query),
          )
          .toList();
    }
    _currentPage = 1;
    setState(() {});
  }

  //  Diálogo Agregar / Editar
  void _mostrarDialogo({Roles? roles}) {
    if (roles != null) {
      _nombreController.text = roles.nombre;
      _descripcionController.text = roles.descripcion;
    } else {
      _nombreController.clear();
      _descripcionController.clear();
    }

    showCustomDialog(
      context: context,
      title: roles == null ? "Agregar Roles" : "Editar Roles",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(controller: _nombreController, label: "Nombre"),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _descripcionController,
            label: "Descripción",
          ),
        ],
      ),
      onSave: () async {
        if (roles == null) {
          await _service.addRol(
            Roles(
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
            ),
          );
        } else {
          await _service.updateRol(
            roles.idRol!,
            Roles(
              idRol: roles.idRol,
              nombre: _nombreController.text,
              descripcion: _descripcionController.text,
            ),
          );
        }
        _refresh();
      },
    );
  }

  // Confirmar eliminación
  void _confirmarEliminar(Roles roles) {
    final colors = Theme.of(context).colorScheme;

    showCustomDialog(
      context: context,
      title: "Eliminar Rol",
      content: Text(
        "¿Seguro que deseas eliminar '${roles.nombre}'?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteRol(roles.idRol!);
        _refresh();
      },
      saveLabel: "Eliminar",
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    final totalPages = (_filteredRoles.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage).clamp(
      0,
      _filteredRoles.length,
    );
    final rolesPagina = _filteredRoles.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primaryContainer,
        title: Text(
          "Roles",
          style: fonts.titleMedium?.copyWith(color: colors.onPrimaryContainer),
        ),
        iconTheme: IconThemeData(color: colors.onPrimaryContainer),
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              label: "Buscar Roles...",
            ),
          ),
          // Botón agregar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomCreateButton(
              label: "Agregar Roles",
              onPressed: () => _mostrarDialogo(),
            ),
          ),
          //  Lista de Roles
          Expanded(
            child: _filteredRoles.isEmpty
                ? Center(child: Text("No hay Roles", style: fonts.bodyMedium))
                : ListView.builder(
                    itemCount: rolesPagina.length,
                    itemBuilder: (context, index) {
                      final roles = rolesPagina[index];
                      return CustomCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            roles.nombre,
                            style: fonts.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            roles.descripcion,
                            style: fonts.bodyMedium,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _mostrarDialogo(roles: roles),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmarEliminar(roles),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          //  Controles de paginación
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PaginacionControls(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
