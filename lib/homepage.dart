import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['categories'];
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Food Categories',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCustomCard(
                    context,
                    imageUrl: category['strCategoryThumb'],
                    title: category['strCategory'],
                    subtitle: category['strCategoryDescription'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryMealsPage(
                            category: category['strCategory'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCustomCard(BuildContext context,
      {required String imageUrl,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryMealsPage extends StatefulWidget {
  final String category;

  const CategoryMealsPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryMealsPageState createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  List meals = [];

  @override
  void initState() {
    super.initState();
    fetchMealsByCategory();
  }

  Future<void> fetchMealsByCategory() async {
    final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          meals = data['meals'];
        });
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (error) {
      print('Error fetching meals: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.category,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: meals.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailPage(mealId: meal['idMeal']),
                        ),
                      );
                    },
                    child: _buildMealCard(
                      imageUrl: meal['strMealThumb'],
                      name: meal['strMeal'],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildMealCard({required String imageUrl, required String name}) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class MealDetailPage extends StatefulWidget {
  final String mealId;

  const MealDetailPage({Key? key, required this.mealId}) : super(key: key);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  Map<String, dynamic>? mealDetail;

  @override
  void initState() {
    super.initState();
    fetchMealDetail();
  }

  Future<void> fetchMealDetail() async {
    final url =
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mealDetail = data['meals'][0];
        });
      } else {
        throw Exception('Failed to load meal details');
      }
    } catch (error) {
      print('Error fetching meal detail: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Det")
      ),
      body: SingleChildScrollView(
        child: mealDetail == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(mealDetail!['strMealThumb']),
                    SizedBox(height: 16),
                    Text(
                      mealDetail!['strMeal'],
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Category: ${mealDetail!['strCategory']}"),
                        Text("Area: ${mealDetail!['strArea']}"),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text("Instructions: ${mealDetail!['strInstructions']}"),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        launch(mealDetail!['strYoutube']);
                      },
                      child: Text("Watch Tutorial"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}
