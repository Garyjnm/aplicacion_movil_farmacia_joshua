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
      
      print("Error al cargar clientes: $error");
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
              (cliente.nombre ?? '').toLowerCase().contains(query) ||
              (cliente.apellido ?? '').toLowerCase().contains(query))
          .toList();
    }
    _currentPage = 1; 
    setState(() {});
  }


  void _mostrarDialogo({ClienteModel? cliente}) {
    if (cliente != null) {
      _nombreController.text = cliente.nombre ?? '';
      _apellidoController.text = cliente.apellido ?? '';
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
        "¿Seguro que deseas desactivar a '${cliente.nombre ?? ''} ${cliente.apellido ?? ''}'?",
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primaryContainer,
        title: Text(
          "Clientes",
          style: fonts.titleLarge?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onPrimaryContainer),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController, 
              label: "Buscar cliente por nombre o apellido...",
            ),
          ),
          // Botón agregar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomCreateButton(
              label: "Agregar Cliente",
              onPressed: () => _mostrarDialogo(),
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          // CORRECCIÓN FINAL: Usa ?? '' para manejar null y mostrar el texto correctamente.
                          '${cliente.nombre ?? ''} ${cliente.apellido ?? ''}',
                          style: fonts.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          // CORRECCIÓN FINAL: Usa ?? 'N/A' para manejar null en el ID.
                          'ID: ${cliente.idCliente ?? 'N/A'}', 
                          style: fonts.bodyMedium
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _mostrarDialogo(cliente: cliente),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _confirmarEliminar(cliente),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Controles de paginación
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