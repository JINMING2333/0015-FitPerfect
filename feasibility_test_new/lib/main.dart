import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/pose_compare_page.dart';
import 'screens/exercise_history_page.dart';
import 'screens/community_page.dart';
import 'screens/settings_page.dart';
import 'screens/pose_image_test_page.dart';
import 'screens/breakthrough_mode_page.dart';
import 'screens/recommended_sports_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/favorites_page.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'services/community_service.dart';
import 'services/post_dialog_service.dart';
import 'services/supabase_service.dart';
import 'services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint(details.stack.toString());
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 初始化Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 初始化Supabase
  await SupabaseService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserDataService()),
        ChangeNotifierProvider(create: (_) => CommunityService()),
        ChangeNotifierProvider(create: (_) => PostDialogService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
      ],
      child: MaterialApp(
        title: '姿势教练',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'NotoSansSC',
        ),
        home: const SplashPage(),
        routes: {
          '/onboarding': (context) => const OnboardingPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/favorites': (context) => const FavoritesPage(),
          '/home': (context) {
            final Object? args = ModalRoute.of(context)?.settings.arguments;
            return MainNavigationPage(
              initialIndex: args is int ? args : 0,
            );
          },
          '/pose_compare': (context) {
            final Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args is String) {
              return PoseComparePage(exerciseId: args);
            } else if (args is Map<String, dynamic>) {
              return PoseComparePage(
                exerciseId: args['exerciseId'] as String,
                name: args['name'] as String?,
                level: args['level'] as int?,
              );
            }
            return const PoseComparePage();
          },
          '/test_image_pose': (context) => const PoseImageTestPage(),
          '/breakthrough_mode': (context) {
            final Object? args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map<String, dynamic>) {
              return BreakthroughModePage(
                selectedSport: args['name'] as String,
              );
            }
            return const BreakthroughModePage();
          },
          '/recommended_sports': (context) => const RecommendedSportsPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  
  final List<Widget> _pages = [
    const RecommendedSportsPage(),
    const ExerciseHistoryPage(),
    const CommunityPage(),
    const SettingsPage(),
  ];
  
  final List<String> _titles = ['Home', 'History', 'Community', 'Settings'];

  @override
  Widget build(BuildContext context) {
    // Get tab index from route arguments, if available
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is int && args != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = args;
        });
      });
    }
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _titles[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: _titles[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: _titles[2],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: _titles[3],
          ),
        ],
      ),
    );
  }
}