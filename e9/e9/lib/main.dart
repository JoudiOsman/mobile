import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruits App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FruitListScreen(),
    );
  }
}

class Fruit {
  final String name;
  final String color;

  Fruit({required this.name, required this.color});
}

class FruitListScreen extends StatefulWidget {
  @override
  _FruitListScreenState createState() => _FruitListScreenState();
}

class _FruitListScreenState extends State<FruitListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  final List<Fruit> fruits = [
    Fruit(name: 'Apple', color: 'Red'),
    Fruit(name: 'Banana', color: 'Yellow'),
    Fruit(name: 'Orange', color: 'Orange'),
    Fruit(name: 'Grapes', color: 'Purple'),
    Fruit(name: 'Strawberry', color: 'Red'),
    Fruit(name: 'Blueberry', color: 'Blue'),
    Fruit(name: 'Watermelon', color: 'Green'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fruits List',
          style: TextStyle(color: Colors.white), // Set the app bar text color to white
        ),
        backgroundColor: Colors.blue, // Set the app bar color to blue
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: fruits.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(fruits[index].name),
                  subtitle: Text('Color: ${fruits[index].color}'),
                );
              },
            ),
    );
  }
}