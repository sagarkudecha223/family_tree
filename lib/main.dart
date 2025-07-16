import 'package:flutter/material.dart';
import 'ui/family_tree_screen.dart';

void main() {
  runApp(FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tree',
      debugShowCheckedModeBanner: false,
      home: FamilyTreeScreen(),
    );
  }
}
