import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFirstLaunch = true; // Default to first launch

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Check if this is the first launch
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if first_launch key exists
      final bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
      
      debugPrint('App state: firstLaunch=${isFirstLaunch}');
      
      setState(() {
        _isFirstLaunch = isFirstLaunch;
      });
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
      setState(() {
        _isFirstLaunch = true; // Default to first launch on error
      });
    }
  }

  // Button click event handler
  void _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      debugPrint('Navigating to next screen: firstLaunch=${_isFirstLaunch}, isLoggedIn=${authService.isLoggedIn}');
      
      if (_isFirstLaunch) {
        // If first launch, mark as not first launch and navigate to onboarding
        debugPrint('Saving first launch state as false');
        await prefs.setBool('first_launch', false);
        
        if (mounted) {
          debugPrint('Navigating to: /onboarding');
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      } else {
        // Not first launch, decide based on login state
        if (authService.isLoggedIn) {
          // Already logged in, go to home
          if (mounted) {
            debugPrint('Navigating to: /home (logged in)');
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Not logged in, go to login
          if (mounted) {
            debugPrint('Navigating to: /login (not logged in)');
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Default to onboarding on error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8E8A7), // Yellow background
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top spacing
              const SizedBox(height: 60),
              
              // Main content - White card with exercise image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          // Show fallback icon if image not found
                          errorBuilder: (ctx, error, _) => Container(
                            color: Colors.white,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 120,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Healthy Exercise',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Title and subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  children: [
                    // App main title - Time to exercise
                    FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        'Time to exercise',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32), // Dark green
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // App slogan - Real-time feedback
                    FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        'Follow us,\nand get real-time feedback.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                    // Add status display for debugging
                    const SizedBox(height: 10),
                    Text(
                      'Status: ${_isFirstLaunch ? "First Launch" : "Not First Launch"}, ${authService.isLoggedIn ? "Logged In" : "Not Logged In"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom button - Let's get started
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 48.0),
                child: ScaleTransition(
                  scale: _animation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _navigateToNextScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Dark green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        "let's get started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
