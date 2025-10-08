import 'package:flutter/material.dart';
import '../../../data/models/usuario.dart';
import '../../../data/services/usuarios_service.dart';
import '../../core/widgets/paginacion_controls.dart'; // Control de paginación
import '../../core/widgets/custom_create_button.dart'; // Botón "Agregar"
import '../../core/widgets/custom_card.dart'; // Tarjeta personalizada
import '../../core/widgets/custom_textfield.dart'; // Campo de texto personalizado
import '../../core/widgets/custom_dialog.dart'; // Diálogo personalizado

// Definimos la clase principal de la pantalla de usuarios
class UsuariosScreen extends StatefulWidget {
  // Constructor del widget, en este caso sin parámetros
  const UsuariosScreen({Key? key}) : super(key: key);

  // Crea el estado del widget
  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

// Estado de la pantalla que contendrá toda la lógica y datos
class _UsuariosScreenState extends State<UsuariosScreen> {
  // Servicio para manejar la comunicación con el backend (por ahora comentado)
final UsuarioService _service = UsuarioService();

  // Controladores para los campos del formulario (para escribir texto)
  final TextEditingController _nombresController = TextEditingController(); // Para el campo "Nombres"
  final TextEditingController _apellidosController = TextEditingController(); // Para "Apellidos"
  final TextEditingController _nombreUsuarioController = TextEditingController(); // Para "Nombre de Usuario"
  final TextEditingController _contrasenaController = TextEditingController(); // Para "Contraseña" (comentado por ahora)
  final TextEditingController _idRolController = TextEditingController(); // Para el ID del rol
  final TextEditingController _searchController = TextEditingController(); // Para la barra de búsqueda

  // Variables para manejar la paginación
  int _currentPage = 1; // Página actual (inicia en 1)
  final int _itemsPerPage = 5; // Cuántos usuarios mostrar por página

  // Listas donde se guardarán todos los usuarios y los filtrados
  List<Usuario> _allUsuarios = []; // Lista completa
  List<Usuario> _filteredUsuarios = []; // Lista filtrada según búsqueda

  // Método que se ejecuta al inicializar el widget
  @override
  void initState() {
    super.initState(); // Llama al método del padre
    _loadUsuarios(); // Carga los usuarios desde el backend
    _searchController.addListener(_filterUsuarios); // Cada vez que se escribe, filtra
  }

  // Método para obtener usuarios del backend
  void _loadUsuarios() {
    // Cómo se haría con el servicio
    _service.getUsuariosByEstado(1).then((data) {
      setState(() {
         _allUsuarios = data; // Asignar todos los usuarios
         _filteredUsuarios = List.from(data); // Copiar los mismos usuarios filtrados
      });
    });
  }

  // Método para recargar usuarios (se usa después de agregar/editar/eliminar)
  void _refresh() {
    _loadUsuarios(); // Simplemente vuelve a cargar los usuarios
  }

  // Método para filtrar usuarios por texto de búsqueda
  void _filterUsuarios() {
    final query = _searchController.text.toLowerCase(); 
    setState(() {
      _filteredUsuarios = _allUsuarios.where((u) {
        return u.nombres.toLowerCase().contains(query) ||
               u.apellidos.toLowerCase().contains(query) ||
               u.nombreUsuario.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1;
    });
  }

 // Método que muestra el diálogo de agregar o editar usuario
  void _mostrarDialogo({Usuario? usuario}) {
    if (usuario != null) { // Si se recibe un usuario, es edición
      _nombresController.text = usuario.nombres; // Llena el campo nombres
      _apellidosController.text = usuario.apellidos; // Llena apellidos
      _nombreUsuarioController.text = usuario.nombreUsuario; // Llena nombre de usuario
      _contrasenaController.clear(); // Limpia la contraseña (no se muestra)
      _idRolController.text = usuario.idRol.toString(); // Llena el rol
    } else { // Si es nuevo usuario
      _nombresController.clear(); // Limpia los campos
      _apellidosController.clear();
      _nombreUsuarioController.clear();
      _contrasenaController.clear();
      _idRolController.clear();
    }

    // Muestra el diálogo personalizado
    showCustomDialog(
      context: context,
      title: usuario == null ? "Agregar Usuario" : "Editar Usuario", // Título dinámico
      content: Column( // Contenido del diálogo
        mainAxisSize: MainAxisSize.min, // Ajusta tamaño según contenido
        children: [
          CustomTextField(controller: _nombresController, label: "Nombres"), // Campo para nombres
          const SizedBox(height: 12), // Espacio
          CustomTextField(controller: _apellidosController, label: "Apellidos"), // Campo apellidos
          const SizedBox(height: 12),
          CustomTextField(controller: _nombreUsuarioController, label: "Nombre de Usuario"), // Campo usuario
          const SizedBox(height: 12),
          CustomTextField(controller: _contrasenaController, label: "Contraseña", obscureText: true), // Campo contraseña
          const SizedBox(height: 12),
          CustomTextField(controller: _idRolController, label: "ID Rol"), // Campo rol
        ],
      ),
      // Acción al guardar
      onSave: () async {
        if (usuario == null) { // Si es nuevo usuario
          await _service.addUsuario(Usuario( // Llama al servicio para crear
            nombres: _nombresController.text, // Toma texto del campo
            apellidos: _apellidosController.text,
            nombreUsuario: _nombreUsuarioController.text,
            contrasena: _contrasenaController.text,
            idRol: int.tryParse(_idRolController.text) ?? 0, // Convierte a número
          ));
        } else { // Si se edita
          await _service.updateUsuario(
            usuario.idUsuario!, // Usa el ID del usuario existente
            Usuario(
              idUsuario: usuario.idUsuario, // Mantiene el mismo ID
              nombres: _nombresController.text,
              apellidos: _apellidosController.text,
              nombreUsuario: _nombreUsuarioController.text,
              contrasena: _contrasenaController.text.isEmpty
                  ? null // Si está vacío, no cambia la contraseña
                  : _contrasenaController.text,
              idRol: int.tryParse(_idRolController.text) ?? 0,
            ),
          );
        }
        _refresh(); // Recarga la lista después de guardar
      },
    );
  }

  // Método para confirmar la eliminación de un usuario
  void _confirmarEliminar(Usuario usuario) {
    final colors = Theme.of(context).colorScheme; // Colores del tema

    // Muestra el diálogo de confirmación
    showCustomDialog(
      context: context,
      title: "Eliminar Usuario", // Título del diálogo
      content: Text( // Mensaje de confirmación
        "¿Seguro que deseas eliminar '${usuario.nombreUsuario}'?",
        style: TextStyle(color: colors.onSurface),
      ),
      onSave: () async {
        await _service.deleteUsuario(usuario.idUsuario!, 0); // Llama al servicio para eliminar
        _refresh(); // Recarga la lista
      },
      saveLabel: "Eliminar", // Texto del botón
    );
  }

  // Método que construye la interfaz visual
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme; // Paleta de colores
    final fonts = Theme.of(context).textTheme; // Tipografía

    // Cálculo para mostrar los elementos por página
    final totalPages = (_filteredUsuarios.length / _itemsPerPage).ceil(); // Total de páginas
    final startIndex = (_currentPage - 1) * _itemsPerPage; // Índice inicial
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, _filteredUsuarios.length); // Índice final (evita overflow)
    final usuariosPagina = _filteredUsuarios.sublist(startIndex, endIndex); // Sublista de usuarios a mostrar

    // Construcción de la interfaz principal
    return Scaffold(
      backgroundColor: colors.surface, // Color de fondo
      appBar: AppBar(
        backgroundColor: colors.primaryContainer, // Fondo del AppBar
        title: Text(
          "Usuarios", // Título de la pantalla
          style: fonts.titleMedium?.copyWith(color: colors.onPrimaryContainer), // Estilo del texto
        ),
        iconTheme: IconThemeData(color: colors.onPrimaryContainer), // Color de íconos
      ),
      body: Column(
        children: [
          // Campo de búsqueda superior
          Padding(
            padding: const EdgeInsets.all(16.0), // Margen
            child: CustomTextField(
              controller: _searchController, // Controlador del texto
              label: "Buscar usuario...", // Etiqueta
            ),
          ),
          // Botón para agregar nuevo usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espaciado
            child: CustomCreateButton(
              label: "Agregar Usuario", // Texto del botón
              onPressed: () => _mostrarDialogo(), // Abre el diálogo
            ),
          ),
          // Lista de usuarios
          Expanded(
            child: _filteredUsuarios.isEmpty // Si no hay usuarios
                ? Center(child: Text("No hay usuarios", style: fonts.bodyMedium)) // Muestra mensaje
                : ListView.builder( // Si hay usuarios, crea una lista
                    itemCount: usuariosPagina.length, // Número de elementos a mostrar
                    itemBuilder: (context, index) { // Constructor de cada ítem
                      final usuario = usuariosPagina[index]; // Usuario actual
                      return CustomCard( // Tarjeta personalizada
                        child: ListTile( // Ítem de lista
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espaciado interno
                          title: Text(
                            "${usuario.nombres} ${usuario.apellidos}", // Nombre completo
                            style: fonts.bodyLarge?.copyWith(fontWeight: FontWeight.bold), // Estilo en negrita
                          ),
                          subtitle: Text(
                            "Usuario: ${usuario.nombreUsuario} • Rol: ${usuario.idRol}", // Subtítulo con rol
                            style: fonts.bodyMedium, // Estilo de texto
                          ),
                          trailing: Row( // Acciones (editar/eliminar)
                            mainAxisSize: MainAxisSize.min, // Ocupa solo lo necesario
                            children: [
                              IconButton( // Botón de editar
                                icon: const Icon(Icons.edit), // Icono de lápiz
                                onPressed: () => _mostrarDialogo(usuario: usuario), // Abre diálogo de edición
                              ),
                              IconButton( // Botón de eliminar
                                icon: const Icon(Icons.delete), // Icono de basurero
                                onPressed: () => _confirmarEliminar(usuario), // Llama al método eliminar
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Controles de paginación
          if (totalPages > 1) // Solo si hay más de una página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8), // Espaciado
              child: PaginacionControls(
                currentPage: _currentPage, // Página actual
                totalPages: totalPages, // Total de páginas
                onPageChanged: (page) { // Callback al cambiar de página
                  setState(() {
                    _currentPage = page; // Actualiza la página
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
