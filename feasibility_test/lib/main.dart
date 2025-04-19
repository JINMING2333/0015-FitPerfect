import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/pose_compare_page.dart';
import 'screens/pose_image_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Compare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PoseComparePage(),
      routes: {
        '/test_image_pose': (context) => const PoseImageTestPage(),
      },
    );
  }
}