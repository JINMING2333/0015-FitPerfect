// lib/screens/community_page.dart
import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社群')),
      body: const Center(child: Text('这里是社群页面')),
    );
  }
}

