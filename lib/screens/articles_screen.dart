import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Importa el paquete
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late Future<List<dynamic>> _articulosFuture;
  late Future<List<dynamic>> _categoriasFuture;
  int? userId; // Almacenamos el nombre de usuario logueado
  List<dynamic> _articulosFiltrados = []; // Lista para los artículos filtrados
  String _searchTerm = ''; // Término de búsqueda

  @override
  void initState() {
    super.initState();
    _articulosFuture = AuthService().getArticulos();
    _categoriasFuture = AuthService().getCategorias();
    _loadUserProfile(); // Cargar el perfil del usuario logueado
    _loadData(); // Cargar datos iniciales
  }
  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService().getProfile();
      setState(() {
        userId = profile['Id']; // Almacenamos el user del usuario logueado
      });
    } catch (e) {
      print('Error al obtener el perfil del usuario: $e');
    }
  }

  void showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nombre de la categoría'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Descripción de la categoría'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Obtener los valores del controlador
                final String name = nameController.text;
                final String description = descriptionController.text;

                if (name.isNotEmpty && description.isNotEmpty) {
                  try {
                    // Llamar a la función para agregar la categoría
                    await AuthService().addCategoria(name, description);
                    // Refrescar la lista de categorías
                    setState(() {
                      _categoriasFuture = AuthService().getCategorias(); // Refresca la lista
                    });
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  } catch (e) {
                    print('Error al agregar la categoría: $e');
                    // Aquí puedes mostrar un mensaje de error si lo deseas
                  }
                } else {
                  // Aquí puedes mostrar un mensaje si los campos están vacíos
                  print('Por favor, completa todos los campos.');
                }
              },
              child: const Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }


 void showAddArticleDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  String articleName = '';
  String articleDescription = '';
  double articlePrice = 0.0;
  int articleStock = 0;
  int authorId = 1; // Asume un ID de autor, cámbialo según tu lógica
  int categoryId = 1; // Se actualizará cuando el usuario seleccione una categoría
  File? imageFile; // Cambiar a nullable para la imagen
  int warrantyPeriod = 0; // Asume un período de garantía, cámbialo según tu lógica

  // Future que trae las categorías desde el AuthService
  Future<List<dynamic>> _fetchCategories() async {
    return await AuthService().getCategorias();
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(16.0), // Espaciado interno
        title: const Text('Agregar Artículo'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
        ),
        content: FutureBuilder<List<dynamic>>(
          future: _fetchCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text('Error al cargar categorías');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No hay categorías disponibles');
            }

            // Lista de categorías
            final categories = snapshot.data!;

            return SingleChildScrollView( // Para permitir desplazamiento
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Nombre del artículo',
                        border: OutlineInputBorder(), // Bordes del campo
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un nombre.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        articleName = value;
                      },
                    ),
                    const SizedBox(height: 8.0), // Espaciado
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Descripción del artículo',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        articleDescription = value;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Por favor, ingresa un precio válido.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        articlePrice = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Por favor, ingresa un stock válido.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        articleStock = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    // DropdownButton para seleccionar categoría
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        hintText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      value: categoryId, // Valor por defecto
                      items: categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        categoryId = value!;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecciona una categoría.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        // Aquí puedes implementar la lógica para seleccionar una imagen
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          imageFile = File(pickedFile.path);
                        }
                      },
                      child: const Text('Seleccionar Imagen'),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Período de Garantía (días)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        warrantyPeriod = int.tryParse(value) ?? 0;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Llama a la función para agregar el artículo
                  await AuthService().addArticulo(
                    articleName,
                    articleDescription,
                    articlePrice,
                    articleStock,
                    authorId,
                    categoryId, // Utiliza el ID de la categoría seleccionada
                    imageFile!, // Asegúrate de que no sea nulo
                    warrantyPeriod,
                  );
                  // Refresca la tabla de artículos
                  setState(() {
                    _articulosFuture = AuthService().getArticulos();
                  });
                  // Cierra el diálogo
                  Navigator.of(context).pop();
                } catch (error) {
                  // Manejo de errores
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error: $error'),
                  ));
                }
              }
            },
            child: const Text('Agregar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );
}



SpeedDial buildSpeedDial() {
  return SpeedDial(
    backgroundColor: Colors.purple,
    icon: Icons.add,
    activeIcon: Icons.close,
    direction: SpeedDialDirection.up, // Define la dirección
    children: [
      SpeedDialChild(
        child: const Icon(Icons.category, color: Colors.white),
        backgroundColor: Colors.green,
        label: 'Agregar Categoría',
        onTap: () => showAddCategoryDialog(context),
      ),
      SpeedDialChild(
        child: const Icon(Icons.article, color: Colors.white),
        backgroundColor: Colors.blue,
        label: 'Agregar Artículo',
        onTap: () => showAddArticleDialog(context),
      ),
    ],
  );
}
 
 Future<void> _loadData() async {
    _articulosFuture = AuthService().getArticulos();
    _categoriasFuture = AuthService().getCategorias();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos y Categorías', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Llama a la función para recargar los datos
          await _loadData();
          setState(() {}); // Forzar la reconstrucción
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Buscador de artículos
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar artículos',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value.toLowerCase(); // Convertimos a minúsculas para la búsqueda
                    });
                  },
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: _articulosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                 _articulosFiltrados = snapshot.data!.where((articulo) {
                 final searchTermLower = _searchTerm.toLowerCase(); // Convertir a minúsculas el término de búsqueda
                 final nameMatches = articulo['name'].toLowerCase().contains(searchTermLower); // Filtrar por nombre
                 final descriptionMatches = articulo['description'].toLowerCase().contains(searchTermLower); // Filtrar por descripción
                 final categoryNameMatches = articulo['category_name'].toLowerCase().contains(searchTermLower); // Filtrar por categoría
                 return nameMatches || descriptionMatches || categoryNameMatches; // Retornar verdadero si cualquiera de los filtros coincide
                 }).toList();


                    return PaginatedArticlesTable(articulos: _articulosFiltrados, userId: userId);
                  } else {
                    return const Text('No hay datos de artículos');
                  }
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<dynamic>>(
                future: _categoriasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return PaginatedCategoriasTable(categorias: snapshot.data!);
                  } else {
                    return const Text('No hay datos de categorías');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      // Aquí se coloca el SpeedDial
      floatingActionButton: buildSpeedDial(), // No necesitas Positioned aquí
    floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Mueve el botón a la izquierda
    );
  }
}

class PaginatedArticlesTable extends StatelessWidget {
  final List<dynamic> articulos;
   final int? userId;  // Recibimos el ID del usuario logueado

  const PaginatedArticlesTable({super.key, required this.articulos, required this.userId});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: Text('Artículos',style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.purple[800],
        ),),
      columns: const [
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Descripción')),
        DataColumn(label: Text('Categoría')),
        DataColumn(label: Text('Acciones')),
      ],
     source: ArticulosDataTableSource(articulos, userId, context), // Pasamos el userId a la fuente de datos
      rowsPerPage: 5,
    );
  }
}

class ArticulosDataTableSource extends DataTableSource {
  final List<dynamic> articulos;
  final int? userId;
  final BuildContext context; // Agregamos el contexto aquí

  ArticulosDataTableSource(this.articulos, this.userId, this.context); // Aceptamos el contexto

  @override
  DataRow getRow(int index) {
    final articulo = articulos[index];
    bool esFavorito = articulo['is_favorito'] ?? false; // Cambia a 'is_favorito'

    print('Articulo ID: ${articulo['id']}, esFavorito: $esFavorito'); // Verifica el estado
    return DataRow(cells: [
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? Colors.red : Colors.black,
              ),
              onPressed: () {
                try {
                } catch (e) {
                  print('Error al convertir el ID del artículo: $e');
                  return; // Salir si no se puede convertir el ID
                }
                // Lógica para agregar o eliminar de favoritos
                if (esFavorito) {
                AuthService().eliminarDeFavoritos(articulo['id'].toString()).then((_) {
                    print('Artículo eliminado de favoritos');
                    articulos[index]['is_favorito'] = false; // Actualizar el estado localmente
                    notifyListeners(); // Notifica los cambios para actualizar la tabla
                  }).catchError((error) {
                    print('Error al eliminar de favoritos: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al eliminar de favoritos.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                } else {
                  AuthService().agregarAFavoritos(articulo['id'].toString()).then((_)  {
                    print('Artículo agregado a favoritos');
                    articulos[index]['is_favorito'] = true; // Actualizar el estado localmente
                    notifyListeners(); // Notifica los cambios para actualizar la tabla
                  }).catchError((error) {
                    print('Error al agregar a favoritos: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al agregar a favoritos.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }
              },
            ),
            Text(articulo['name']), // Nombre del artículo
          ],
        ),
      ),
      DataCell(Text(articulo['description'])),
      DataCell(Text(articulo['category_name'])),
      DataCell(
        Row(
          children: [
            const SizedBox(width: 8), // Espaciado entre el texto y el ícono
            if (articulo['author_id'] == userId) // Mostrar si es el autor
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  int idArticulo;
                  try {
                    idArticulo = int.parse(articulo['id'].toString());
                  } catch (e) {
                    print('Error al convertir el ID del artículo: $e');
                    return; // Salir si no se puede convertir el ID
                  }
                  AuthService().deleteArticulo(idArticulo).then((_) {
                    print('Artículo eliminado correctamente');
                    articulos.removeAt(index); // Elimina el artículo de la lista localmente
                    notifyListeners(); // Notifica los cambios para actualizar la tabla
                  }).catchError((error) {
                    print('Error al eliminar el artículo: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No tienes permiso para eliminar este artículo.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                // Llamar a la función para mostrar los detalles del artículo
                _showArticuloDetails(articulo['id']);
              },
            ),
          ],
        ),
      ),
    ]);
  }

  void _showArticuloDetails(int id) async {
    try {
      // Obtener los detalles del artículo
      final articuloDetail = await AuthService().getArticuloDetailByID(id);
      // Mostrar un diálogo con los detalles del artículo
      showDialog(
        // ignore: use_build_context_synchronously
        context: context, // Usamos el contexto aquí
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(articuloDetail['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 if (articuloDetail['image'] != null && articuloDetail['image'].isNotEmpty)
                  Image.network(articuloDetail['image']),
                const SizedBox(height: 16),
                Text('Descripción: ${articuloDetail['description']}'),
                Text('Categoría: ${articuloDetail['category_name']}'),
                Text('Precio: \$${articuloDetail['price']}'),
                Text('Stock: ${articuloDetail['stock']}'),
                Text('Expiración de garantía: ${articuloDetail['warranty_expiration']}'),
                // Agrega más campos según sea necesario
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener detalles del artículo: $e');
    }
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => articulos.length;
  @override
  int get selectedRowCount => 0;
}

class PaginatedCategoriasTable extends StatefulWidget {
  final List<dynamic> categorias;

  const PaginatedCategoriasTable({super.key, required this.categorias});

  @override
  // ignore: library_private_types_in_public_api
  _PaginatedCategoriasTableState createState() => _PaginatedCategoriasTableState();
}

class _PaginatedCategoriasTableState extends State<PaginatedCategoriasTable> {
  late List<dynamic> _categorias;
  List<dynamic> _filteredCategorias = [];
  // ignore: prefer_final_fields
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categorias = widget.categorias; // Inicializa con las categorías recibidas
     _filteredCategorias = _categorias; // Inicializa con todas las categorías
    _searchController.addListener(_filterCategorias);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategorias() {
    String query = _searchController.text.toLowerCase();
    setState(() {
     _filteredCategorias = _categorias.where((categoria) {
     String name = categoria['name'].toLowerCase();
     String description = categoria['description'].toLowerCase(); // Asegúrate de que 'description' sea el campo correcto
     String queryLower = query.toLowerCase();
     return name.contains(queryLower) || description.contains(queryLower); // Filtrar por nombre o descripción
     }).toList();
    });
  }
  void _editCategoria(BuildContext context, Map<String, dynamic> categoria) {
    showDialog(
      context: context,
      builder: (context) {
        String name = categoria['name'];
        String description = categoria['description'];
        return AlertDialog(
          title: const Text('Editar categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Descripción'),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                Navigator.of(context).pop({
                  'name': name,
                  'description': description,
                });
              },
            ),
          ],
        );
      },
    ).then((editedCategoria) {
      if (editedCategoria != null) {
        // Aquí se llama a la API para editar la categoría
        final authService = AuthService();
        authService.editCategoria(
          categoria['id'],
          editedCategoria['name'],
          editedCategoria['description'],
        ).then((_) {
          // Actualiza la lista local de categorías
          setState(() {
            final index = _categorias.indexWhere((c) => c['id'] == categoria['id']);
            if (index != -1) {
              _categorias[index] = {
                'id': categoria['id'],
                'name': editedCategoria['name'],
                'description': editedCategoria['description'],
              };
            }
          });
          print('Categoría editada correctamente');
        }).catchError((error) {
          print('Error al editar la categoría: $error');
        });
      }
    });
  }
  void _deleteCategoria(BuildContext context, Map<String, dynamic> categoria) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar categoría'),
          content: Text('¿Estás seguro de que deseas eliminar ${categoria['name']}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cerrar sin eliminar
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar eliminación
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        // Llamar a la API para eliminar la categoría
        final authService = AuthService();
        authService.deleteCategoria(categoria['id']).then((_) {
          setState(() {
            _categorias.removeWhere((c) => c['id'] == categoria['id']); // Elimina de la lista local
          });
          print('Categoría eliminada correctamente');
        }).catchError((error) {
          print('Error al eliminar la categoría: $error');
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar categorías',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        PaginatedDataTable(
          header: Text(
            'Categorías',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Acciones')),
          ],
          source: CategoriasDataTableSource(
            categorias: _filteredCategorias,
            onEdit: (categoria) => _editCategoria(context, categoria),
            onDelete: (categoria) => _deleteCategoria(context, categoria),
          ),
          rowsPerPage: 5,
        ),
      ],
    );
  }
}

class CategoriasDataTableSource extends DataTableSource {
  final List<dynamic> categorias;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  CategoriasDataTableSource({
    required this.categorias,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final categoria = categorias[index];

    return DataRow(cells: [
      DataCell(Text(categoria['name'])),
      DataCell(Text(categoria['description'])),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue), // Icono de editar
              onPressed: () {
                // Llamar al callback onEdit
                onEdit(categoria);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red,), // Icono de eliminar
              onPressed: () {
                // Llamar al callback onDelete
                onDelete(categoria);
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => categorias.length;
  @override
  int get selectedRowCount => 0;
}
