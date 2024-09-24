import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart'; // Asegúrate de tener esta dependencia en pubspec.yaml
import 'dart:io'; // Importar para manejar archivos

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final AuthService authService = AuthService();
  List<dynamic> articles = [];
  List<dynamic> categories = [];
  bool isLoading = true;
  File? selectedImage; // Para almacenar la imagen seleccionada

  final TextEditingController articleSearchController = TextEditingController();
  final TextEditingController categorySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final articlesData = await authService.getArticulos();
      final categoriesData = await authService.getCategorias();
      setState(() {
        articles = articlesData;
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al obtener los datos: $e');
    }
  }

  Future<void> handleDelete(int id, bool isArticle) async {
    try {
      isArticle ? await authService.deleteArticulo(id) : await authService.deleteCategoria(id);
      await fetchData();
    } catch (e) {
      debugPrint('Error al eliminar: $e');
    }
  }

  Future<void> handleSave({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int category,
    required double warrantyperiod,
    int? id,
    bool isArticle = true,
  }) async {
    try {
      if (isArticle) {
        if (id == null) {
          await authService.addArticuloWithImage(name, description, price, stock, category, warrantyperiod, selectedImage!);
        } else {
          await authService.editArticulo(id, name, description, price, stock, category, warrantyperiod, selectedImage);
        }
      } else {
        if (id == null) {
          await authService.addCategoria(name, description);
        } else {
          await authService.editCategoria(id, name, description);
        }
      }
      await fetchData();
      setState(() {
        selectedImage = null; // Reinicia la imagen seleccionada
      });
    } catch (e) {
      debugPrint('Error al guardar: $e');
    }
  }
Future<void> searchById(bool isArticle) async {
  try {
    final id = isArticle
        ? int.tryParse(articleSearchController.text) ?? 0
        : int.tryParse(categorySearchController.text) ?? 0;

    if (id > 0) {
      if (isArticle) {
        final article = await authService.getArticuloById(id);
        if (article.isNotEmpty) {
          setState(() {
            articles = [article]; // Muestra el artículo encontrado
          });
        } else {
          setState(() {
            articles = []; // Si no hay artículo, lista vacía
          });
        }
      } else {
        final category = await authService.getCategoriaById(id);
        setState(() {
          // ignore: unnecessary_null_comparison
          categories = category != null ? [category] : [];
        });
      }
    } else {
      await fetchData(); // Recargar todos los artículos si ID no es válido
    }
  } catch (e) {
    debugPrint('Error en la búsqueda: $e');
    setState(() {
      articles = []; // Lista vacía en caso de error
    });
  }
}


  void showDialogForm({
    required String title,
    required TextEditingController nameController,
    TextEditingController? descriptionController,
    TextEditingController? priceController,
    TextEditingController? stockController,
    TextEditingController? categoryController,
    TextEditingController? warrantyperiodController,
    int? id,
    bool isArticle = true,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              if (descriptionController != null)
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              if (priceController != null)
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
              if (stockController != null)
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
              if (categoryController != null)
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  keyboardType: TextInputType.number,
                ),
              if (warrantyperiodController != null)
                TextField(
                  controller: warrantyperiodController,
                  decoration: const InputDecoration(labelText: 'Warranty_Period'),
                  keyboardType: TextInputType.number,
                ),
                
              // Agregar campo para seleccionar imagen
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      selectedImage = File(pickedFile.path);
                    });
                  }
                },
                child: const Text('Seleccionar Imagen'),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(
                    selectedImage!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
         actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            // Validación y conversión antes de pasar los datos a handleSave
            double price = double.tryParse(priceController?.text ?? '0') ?? 0.0;
            int stock = int.tryParse(stockController?.text ?? '0') ?? 0;
            int category = int.tryParse(categoryController?.text ?? '0') ?? 0;
            double warrantyPeriod = double.tryParse(warrantyperiodController?.text ?? '0') ?? 0.0;

            // Llamar a handleSave con los valores convertidos correctamente
            await handleSave(
              name: nameController.text,
              description: descriptionController?.text ?? '',
              price: price,
              stock: stock,
              category: category,
              warrantyperiod: warrantyPeriod,
              id: id,
              isArticle: isArticle,
            );

            // Cerrar el diálogo después de guardar
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  },
);
  }

 void showDeleteDialog(int id, bool isArticle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                handleDelete(id, isArticle);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos y Categorías', style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSearchSection('Buscar Artículo por ID', articleSearchController, () => searchById(true)),
                  buildSectionHeader('Artículos', showAddArticleDialog),
                  articles.isEmpty
                      ? const Center(child: Text('No hay artículos disponibles'))
                      : buildDataTable(items: articles, isArticle: true),
                  const SizedBox(height: 32),
                  buildSearchSection('Buscar Categoría por ID', categorySearchController, () => searchById(false)),
                  buildSectionHeader('Categorías', showAddCategoryDialog),
                  categories.isEmpty
                      ? const Center(child: Text('No hay categorías disponibles'))
                      : buildDataTable(items: categories, isArticle: false),
                ],
              ),
            ),
    );
  }

 Widget buildSearchSection(String label, TextEditingController controller, VoidCallback onSearch) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(  // Usamos Column solo dentro de buildSearchSection para añadir el espacio
      children: [
        const SizedBox(height: 20),  // Espacio adicional entre el header y el buscador
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSearch,
              child: const Text('Buscar'),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildSectionHeader(String title, VoidCallback onAdd) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.purple),
          onPressed: onAdd,
        ),
      ],
    ),
  );
}


  Widget buildDataTable({required List<dynamic> items, required bool isArticle}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: isArticle
            ? const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Categoría')),
                DataColumn(label: Text('Warranty')),
                DataColumn(label: Text('Acciones')),
              ]
            : const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Acciones')),
              ],
        rows: items.map<DataRow>((item) {
          return DataRow(
            cells: isArticle
                ? [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['name'])),
                    DataCell(Text(item['description'].toString())),
                    DataCell(Text(item['price'])),
                  DataCell(Text(item['stock'].toString())),
                    DataCell(Text(item['category'].toString())),
                    DataCell(Text(item['warranty_period'].toString())),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 149, 33, 243)),
                            onPressed: () => showDialogForm(
                              title: 'Editar Artículo',
                              nameController: TextEditingController(text: item['name']),
                              descriptionController: TextEditingController(text: item['description'].toString()),
                              priceController: TextEditingController(text: item['price']),
                              stockController: TextEditingController(text: item['stock'].toString()),
                              categoryController: TextEditingController(text: item['category'].toString()),
                              warrantyperiodController: TextEditingController(text: item['warranty_period'].toString()),
                              id: item['id'],
                              isArticle: isArticle,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDeleteDialog(item['id'], isArticle),
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['name'])),
                    DataCell(Text(item['description'])),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 149, 33, 243)),
                            onPressed: () => showDialogForm(
                              title: 'Editar Categoría',
                              nameController: TextEditingController(text: item['name']),
                              descriptionController: TextEditingController(text: item['description']),
                              id: item['id'],
                              isArticle: false,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDeleteDialog(item['id'], isArticle),
                          ),
                        ],
                      ),
                    ),
                  ],
          );
        }).toList(),
      ),
    );
  }

  void showAddArticleDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();
    final warrantyPeriodcontroller = TextEditingController();

    showDialogForm(
      title: 'Agregar Artículo',
      nameController: nameController,
      descriptionController: descriptionController,
      priceController: priceController,
      stockController: stockController,
      categoryController: categoryController,
      warrantyperiodController: warrantyPeriodcontroller,
    );
  }

  void showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialogForm(
      title: 'Agregar Categoría',
      nameController: nameController,
      descriptionController: descriptionController,
      isArticle: false,
    );
  }
}
