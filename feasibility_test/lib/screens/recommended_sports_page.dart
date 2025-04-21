// lib/screens/recommended_sports_page.dart
import 'package:flutter/material.dart';

class RecommendedSportsPage extends StatelessWidget {
  const RecommendedSportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('推荐运动')),
      body: Center(child: Text('这里是推荐运动页面')),
    );
  }
}
