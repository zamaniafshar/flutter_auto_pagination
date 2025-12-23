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
    return const MaterialApp(home: ComplexExample());
  }
}
