import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text("category")
      ),
    );
  }
}