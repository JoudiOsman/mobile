import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Recipe {
  final String recipeName;
  final String recipeAuthor;
  final String amountOfIngredients;
  final String recipeDifficulty;
  final String cookingTime;
  final int totalLikes;
  final String imageUrl;
  bool isFavourite;
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

class RecipeModel extends ChangeNotifier {
  List<Recipe> recipes = [];
  List<Recipe> favoriteRecipes = [];

  void loadRecipes() async {
    final String jsonString = await rootBundle.loadString('assets/recipe_list.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final List<dynamic> jsonRecipes = jsonData['recipes'];
    recipes = jsonRecipes.map((json) => Recipe.fromJson(json)).toList();
    notifyListeners();
  }

  void toggleFavorite(Recipe recipe) {
    recipe.isFavourite = !recipe.isFavourite;
    if (recipe.isFavourite) {
      favoriteRecipes.add(recipe);
    } else {
      favoriteRecipes.removeWhere((element) => element.recipeName == recipe.recipeName); 
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeModel(),
      child: MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue, // Set the app bar color here
          ),
        ),
        home: RecipesPage(),
      ),
    );
  }
}

class RecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipeModel = Provider.of<RecipeModel>(context);
    if (recipeModel.recipes.isEmpty) {
      recipeModel.loadRecipes();
      return Scaffold(
        appBar: AppBar(title: Text('Recipes')),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Recipes')),
        drawer: AppDrawer(),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: recipeModel.recipes.length,
          itemBuilder: (context, index) {
            return RecipeItem(recipe: recipeModel.recipes[index]);
          },
        ),
      );
    }
  }
}

class FavouriteRecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipeModel = Provider.of<RecipeModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Recipes')),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: recipeModel.favoriteRecipes.length,
        itemBuilder: (context, index) {
          final Recipe recipe = recipeModel.favoriteRecipes[index];
          return ListTile(
            leading: Image.network(
              recipe.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(recipe.recipeName),
          );
        },
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: Text('Recipes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipesPage()),
              );
            },
          ),
          ListTile(
            title: Text('Favorite Recipes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavouriteRecipesPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RecipeItem extends StatelessWidget {
  final Recipe recipe;

  RecipeItem({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipeModel = Provider.of<RecipeModel>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(recipe.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FavouriteButton(recipe: recipe),
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

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.recipeName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            recipe.imageUrl,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                  SizedBox(height: 8),
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map((ingredient) => Text('• $ingredient'))
                        .toList(),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Directions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
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

class FavouriteButton extends StatelessWidget {
  final Recipe recipe;

  FavouriteButton({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipeModel = Provider.of<RecipeModel>(context);
    return GestureDetector(
      onTap: () {
        recipeModel.toggleFavorite(recipe);
      },
      child: Icon(
        recipe.isFavourite ? Icons.favorite : Icons.favorite_border,
        color: recipe.isFavourite ? Colors.red : Colors.white,
      ),
    );
  }
}
