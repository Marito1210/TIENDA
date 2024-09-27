import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

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
        print(articles);
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al obtener los datos: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artículos y Categorías',  style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader('Artículos'),
                  articles.isEmpty
                      ? const Center(child: Text('No hay artículos disponibles'))
                      : buildDataTable(items: articles, isArticle: true),
                  const SizedBox(height: 32),
                  buildSectionHeader('Categorías'),
                  categories.isEmpty
                      ? const Center(child: Text('No hay categorías disponibles'))
                      : buildDataTable(items: categories, isArticle: false),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.purple[800],
        ),
      ),
    );
  }

  Widget buildDataTable({required List<dynamic> items, required bool isArticle}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: isArticle
            ? const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Categoría')),
                DataColumn(label: Text('Acciones')), // Nueva columna
              ]
            : const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Descripción')),
              ],
        rows: items.map<DataRow>((item) {
          return DataRow(
            cells: isArticle
                ? [
                    DataCell(Text(item['name'].toString())),
                    DataCell(Text(item['description']?.toString() ?? 'No description')),
                    DataCell(Text(item['category_name'].toString())),
                   DataCell(IconButton(
                       icon: const Icon(Icons.info),
                     onPressed: () => _showArticleDetails(item['id']),

                    )),

                  ]
                : [
                    DataCell(Text(item['id'].toString())),
                    DataCell(Text(item['name'].toString())),
                    DataCell(Text(item['description'] ?? '')),
                  ],
          );
        }).toList(),
      ),
    );
  }

// Método para mostrar los detalles del artículo
void _showArticleDetails(int articleId) async {
  try {
    final articleDetails = await authService.getArticuloDetailByID(articleId);
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(articleDetails['name'] ?? 'Nombre no disponible'),
          content: SingleChildScrollView(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen del artículo
                    if (articleDetails['image'] != null && articleDetails['image'].isNotEmpty)
                      Image.network(articleDetails['image']),
                    const SizedBox(height: 16),

                    // Descripción
                    Text(
                      'Descripción: ${articleDetails['description'] ?? 'Descripción no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Categoría
                    Text(
                      'Categoría: ${articleDetails['category_name'] ?? 'Categoría no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Autor
                    Text(
                      'Autor: ${articleDetails['author_name'] ?? 'Autor no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Precio
                    Text(
                      'Precio: \$${articleDetails['price']?.toString() ?? 'Precio no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Stock
                    Text(
                      'Stock: ${articleDetails['stock']?.toString() ?? 'Stock no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Fecha de creación
                    Text(
                      'Creado el: ${articleDetails['created_at']?.toString() ?? 'Fecha no disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Expiración de garantía
                    Text(
                      'Expiración de garantía: ${articleDetails['warranty_expiration']?.toString() ?? 'No disponible'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    debugPrint('Error al obtener los detalles del artículo: $e');
  }
}



  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva categoría'),
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
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Agregar'),
              onPressed: () async {
                final String name = nameController.text;
                final String description = descriptionController.text;

                if (name.isNotEmpty && description.isNotEmpty) {
                  await authService.addCategoria(name, description);
                  Navigator.of(context).pop();
                  fetchData(); // Refrescar los datos después de agregar la categoría
                }
              },
            ),
          ],
        );
      },
    );
  }
}
