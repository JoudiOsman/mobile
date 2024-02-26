import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class Recipe {
  final String recipeName;
  final String recipeAuthor;
  final String amountOfIngredients;
  final String recipeDifficulty;
  final String cookingTime;
  final int totalLikes;
  final String imageUrl;
  final bool isFavourite;
  final String description;
  final List<String> ingredients;
  final List<String> directions;
  final int cookTime;

  Recipe({
    required this.recipeName,
    required this.recipeAuthor,
    required this.amountOfIngredients,
    required this.recipeDifficulty,
    required this.cookingTime,
    required this.totalLikes,
    required this.imageUrl,
    required this.isFavourite,
    required this.description,
    required this.ingredients,
    required this.directions,
    required this.cookTime,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeName: json['recipeName'],
      recipeAuthor: json['recipeAuthor'],
      amountOfIngredients: json['amountOfIngredients'],
      recipeDifficulty: json['recipeDifficulty'],
      cookingTime: json['cookingTime'],
      totalLikes: json['totalLikes'],
      imageUrl: json['imageUrl'],
      isFavourite: json['isFavourite'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      directions: List<String>.from(json['directions']),
      cookTime: json['cookTime'],
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    final String jsonString =
        await rootBundle.loadString('assets/recipe_list.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final List<dynamic> jsonRecipes = jsonData['recipes'];
    setState(() {
      recipes = jsonRecipes.map((json) => Recipe.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
            title: Text(
              'Recipes',
              style: TextStyle(color: Colors.white), // Set the text color to white
            ),
             
        ),
        
        body: SingleChildScrollView(
          child: recipes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return GridItem(recipe: recipes[index]);
                  },
                ),
        ),
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final Recipe recipe;

  const GridItem({required this.recipe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  recipe.isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        recipe.amountOfIngredients,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${recipe.cookTime} minutes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.align_vertical_bottom_sharp,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        recipe.recipeDifficulty,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({required this.recipe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          recipe.recipeName,
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipe Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.recipeName),
                  Text(
                    'Recipe Author: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.recipeAuthor),
                  Text(
                    'Amount of Ingredients: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.amountOfIngredients),
                  Text(
                    'Recipe Difficulty: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.recipeDifficulty),
                  Text(
                    'Cooking Time: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.cookingTime),
                  Text(
                    'Total Likes: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.totalLikes.toString()),
                  Text(
                    'Description: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipe.description),
                  const SizedBox(height: 8),
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map((ingredient) => Text('• $ingredient'))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Directions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.directions
                        .asMap()
                        .entries
                        .map(
                          (entry) => Text(
                            '${entry.key + 1}. ${entry.value}',
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}