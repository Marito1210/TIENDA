import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

class ArticlesScreen extends StatefulWidget {
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
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al obtener los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Artículos y Categorías',
           style: TextStyle(color: Colors.white),
           ),
        backgroundColor: Colors.purple, // Color morado para la barra de la aplicación
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de artículos
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Artículos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800], // Color morado oscuro
                      ),
                    ),
                  ),
                  
                  // Lista de artículos
                  articles.isEmpty
                      ? Center(child: Text('No hay artículos disponibles'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: Icon(
                                  Icons.article,
                                  color: Colors.purple[300], // Icono morado claro
                                  size: 40,
                                ),
                                title: Text(
                                  article['name'] ?? 'Sin título',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['description'] ?? 'Sin descripción',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Precio: \$${article['price'] ?? 'No disponible'}',
                                          style: TextStyle(fontSize: 16, color: Colors.green),
                                        ),
                                        Text(
                                          'Stock: ${article['stock'] ?? 'No disponible'}',
                                          style: TextStyle(fontSize: 16, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Acción al tocar el artículo
                                },
                              ),
                            );
                          },
                        ),

                  SizedBox(height: 20), // Separador entre artículos y categorías

                  // Título de categorías
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800], // Color morado oscuro
                      ),
                    ),
                  ),

                  // Lista de categorías
                  categories.isEmpty
                      ? Center(child: Text('No hay categorías disponibles'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: Icon(
                                  Icons.category,
                                  color: Colors.purple[300], // Icono morado claro
                                  size: 40,
                                ),
                                title: Text(
                                  category['name'] ?? 'Sin nombre',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  category['description'] ?? 'Sin descripción',
                                  style: TextStyle(fontSize: 16),
                                ),
                                onTap: () {
                                  // Acción al tocar la categoría
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
