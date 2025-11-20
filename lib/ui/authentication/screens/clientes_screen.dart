import 'package:flutter/material.dart';
import '../../../data/models/cliente.dart'; 
import '../../../data/services/cliente_service.dart'; 
import '../../core/widgets/paginacion_controls.dart';
import '../../core/widgets/custom_create_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/custom_dialog.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ClientesScreen extends StatefulWidget {
  static const String routeName = '/Clientes';
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClientesService _service = ClientesService();
  late Future<List<ClienteModel>> _futureClientes;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 5; 

  List<ClienteModel> _allClientes = []; 
  List<ClienteModel> _filteredClientes = []; 

  @override
  void initState() {
    super.initState();
    _loadClientes();
    _searchController.addListener(_filterClientes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClientes);
    _searchController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }


  void _loadClientes() {
    _futureClientes = _service.getClientes(estado: 1); 
    _futureClientes.then((data) {
      _allClientes = data;
      _filteredClientes = List.from(_allClientes); 
      _filterClientes(); 
      setState(() {});
    }).catchError((error) {
      debugPrint("Error al cargar clientes: $error");
      setState(() {
        _allClientes = [];
        _filteredClientes = [];
      });
    });
  }

  void _refresh() {
    _loadClientes();
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredClientes = List.from(_allClientes);
    } else {
      _filteredClientes = _allClientes
          .where((cliente) =>
              cliente.nombre.toLowerCase().contains(query) ||
              cliente.apellido.toLowerCase().contains(query))
          .toList();
    }
    _currentPage = 1; 
    setState(() {});
  }


  void _mostrarDialogo({ClienteModel? cliente}) {
    if (cliente != null) {
      _nombreController.text = cliente.nombre;
      _apellidoController.text = cliente.apellido;
    } else {
      _nombreController.clear();
      _apellidoController.clear();
    }

    showCustomDialog(
      context: context,
      title: cliente == null ? "Agregar Cliente" : "Editar Cliente",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(controller: _nombreController, label: "Nombre"),
          const SizedBox(height: 12),
          CustomTextField(controller: _apellidoController, label: "Apellido"),
        ],
      ),
      onSave: () async {
        final newCliente = ClienteModel(
          idCliente: cliente?.idCliente, 
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
        );

        if (cliente == null) {
          await _service.addCliente(newCliente);
        } else {
          await _service.updateCliente(cliente.idCliente!, newCliente); 
        }
        _refresh();
      },
      saveLabel: cliente == null ? "Guardar" : "Actualizar",
    );
  }

  void _confirmarEliminar(ClienteModel cliente) {
    final colors = Theme.of(context).colorScheme;

    showCustomDialog(
      context: context,
      title: "Desactivar Cliente",
      content: Text(
        "¿Seguro que deseas desactivar a '${cliente.nombre} ${cliente.apellido}'?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteCliente(cliente.idCliente!, estado: 0); 
        _refresh();
      },
      saveLabel: "Desactivar",
    );
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fonts = Theme.of(context).textTheme;

    final totalPages = (_filteredClientes.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, _filteredClientes.length);
    final clientesPagina = _filteredClientes.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Barra superior con buscador y botón refrescar
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _searchController,
                  label: "Buscar cliente por nombre o apellido...",
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refrescar',
                onPressed: _refresh,
              ),
            ],
          ),
        ),
          // Botón agregar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomCreateButton(
              label: "Agregar Cliente",
              onPressed: () => _mostrarDialogo(),
              alignment: Alignment.centerLeft,
            ),
          ),
          // Lista de clientes
        Expanded(
          child: FutureBuilder<List<ClienteModel>>(
              future: _futureClientes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                   return Center(child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center));
                }

                if (_filteredClientes.isEmpty && _allClientes.isNotEmpty) {
                    return Center(child: Text("No se encontraron resultados para la búsqueda.", style: fonts.bodyMedium));
                }

                if (_allClientes.isEmpty) {
                   return Center(child: Text("No hay clientes activos.", style: fonts.bodyMedium));
                }

                return ListView.builder(
                  itemCount: clientesPagina.length,
                  itemBuilder: (context, index) {
                    final cliente = clientesPagina[index];
                    return CustomCard(
                      title: '${cliente.nombre} ${cliente.apellido}',
                      subtitle: 'ID: ${cliente.idCliente ?? 'N/A'}',
                      actions: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: Icon(Icons.edit, color: colors.secondaryContainer),
                          onPressed: () => _mostrarDialogo(cliente: cliente),
                        ),
                        IconButton(
                          tooltip: 'Desactivar',
                          icon: Icon(Icons.delete, color: colors.error),
                          onPressed: () => _confirmarEliminar(cliente),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Controles de paginación
        if (totalPages > 1)
          SafeArea(
            top: false,
            child: Padding(
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
          ),
      ],
    );
  }
}