import 'package:example/complex_example/complex_example.dart';
import 'package:example/simple_example/manual_loading.dart';
import 'package:example/simple_example/simple_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Pagination Examples'),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SimpleExample(),
                  ),
                );
              },
              child: const Text('Simple Example (Auto Load More)'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ManualLoadMoreExample(),
                  ),
                );
              },
              child: const Text('Manual Load More Example'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ComplexExample(),
                  ),
                );
              },
              child: const Text('Manual Load More Example'),
            ),
          ),
        ],
      ),
    );
  }
}
