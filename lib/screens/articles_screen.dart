import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final AuthService authService = AuthService();
  List<dynamic> articles = [];
  List<dynamic> categories = [];
  bool isLoading = true;

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
      setState(() {
        isLoading = false;
      });
      // ignore: avoid_print
      print('Error al obtener los datos: $e');
    }
  }

  Future<void> deleteArticle(int id) async {
    try {
      await authService.deleteArticulo(id);
      await fetchData();
    } catch (e) {
      // ignore: avoid_print
      print('Error al eliminar el artículo: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await authService.deleteCategoria(id);
      await fetchData();
    } catch (e) {
      // ignore: avoid_print
      print('Error al eliminar la categoría: $e');
    }
  }

  void showEditArticleDialog(dynamic article) {
    final nameController = TextEditingController(text: article['name']);
    final descriptionController = TextEditingController(text: article['description']);
    final priceController = TextEditingController(text: article['price'].toString());
    final stockController = TextEditingController(text: article['stock'].toString());
    final categoryController = TextEditingController(text: article['category'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Artículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
               TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authService.editArticulo(
                  article['id'],
                  nameController.text,
                  descriptionController.text,
                  double.tryParse(priceController.text) ?? 0.0,
                  int.tryParse(stockController.text) ?? 0,
                  int.tryParse(categoryController.text) ?? 0,
                );
                await fetchData();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void showEditCategoryDialog(dynamic category) {
    final nameController = TextEditingController(text: category['name']);
    final descriptionController = TextEditingController(text: category['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authService.editCategoria(
                  category['id'],
                  nameController.text,
                  descriptionController.text,
                );
                await fetchData();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void showAddArticleDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Artículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authService.addArticulo(
                  nameController.text,
                  descriptionController.text,
                  double.tryParse(priceController.text) ?? 0.0,
                  int.tryParse(stockController.text) ?? 0,
                  int.tryParse(categoryController.text) ?? 0,
                );
                await fetchData();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await authService.addCategoria(
                  nameController.text,
                  descriptionController.text,
                );
                await fetchData();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
//metodo eliminar articulo
  void showDeleteArticleDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Artículo'),
          content: const Text('¿Estás seguro de que deseas eliminar este artículo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteArticle(id);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
//metodo eliminar categoria
  void showDeleteCategoryDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Categoría'),
          content: const Text('¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteCategory(id);
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
        title: const Text(
          'Artículos y Categorías',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Artículos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.purple),
                          onPressed: showAddArticleDialog,
                        ),
                      ],
                    ),
                  ),

                  articles.isEmpty
                      ? const Center(child: Text('No hay artículos disponibles'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Descripción')),
                              DataColumn(label: Text('Precio')),
                              DataColumn(label: Text('Stock')),
                              DataColumn(label: Text('ID_Categoria')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: articles.map<DataRow>((article) {
                              return DataRow(cells: [
                                DataCell(Text(article['id'].toString())),
                                DataCell(Text(article['name'])),
                                DataCell(Text(article['description'])),
                                DataCell(Text(article['price'].toString())),
                                DataCell(Text(article['stock'].toString())),
                                DataCell(Text(article['category'].toString())),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color.fromARGB(255, 166, 33, 243)),
                                      onPressed: () => showEditArticleDialog(article),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => showDeleteArticleDialog(article['id']),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categorías',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.purple),
                          onPressed: showAddCategoryDialog,
                        ),
                      ],
                    ),
                  ),
                  categories.isEmpty
                      ? const Center(child: Text('No hay categorías disponibles'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Descripción')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: categories.map<DataRow>((category) {
                              return DataRow(cells: [
                                DataCell(Text(category['id'].toString())),
                                DataCell(Text(category['name'])),
                                DataCell(Text(category['description'])),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color.fromARGB(255, 166, 33, 243)),
                                      onPressed: () => showEditCategoryDialog(category),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => showDeleteCategoryDialog(category['id']),
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
