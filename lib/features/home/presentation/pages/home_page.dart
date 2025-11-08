import 'package:flutter/material.dart';

import 'package:loom/features/home/presentation/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    //Scaffold
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      //DRAWER
      drawer: MyDrawer(),
    );
  }
}
