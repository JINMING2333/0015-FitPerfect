import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _saveTrainingHistory = true;
  double _cameraQuality = 0.5; // 0.0 - 1.0
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light Mode';
  
  final List<String> _availableLanguages = [
    'English',
    'Simplified Chinese',
    'Japanese',
    'Korean',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _saveTrainingHistory = prefs.getBool('save_training_history') ?? true;
        _cameraQuality = prefs.getDouble('camera_quality') ?? 0.5;
        _selectedLanguage = prefs.getString('selected_language') ?? 'English';
        _selectedTheme = prefs.getString('selected_theme') ?? 'Light Mode';
      });
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
      await prefs.setBool('save_training_history', _saveTrainingHistory);
      await prefs.setDouble('camera_quality', _cameraQuality);
      await prefs.setString('selected_language', _selectedLanguage);
      await prefs.setString('selected_theme', _selectedTheme);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    } catch (e) {
      debugPrint('Failed to save settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save settings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notification Settings'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive training reminders'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          
          _buildSectionHeader('App Settings'),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_selectedTheme),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showThemeDialog();
            },
          ),
          const Divider(),
          
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show terms of service
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show privacy policy
            },
          ),
          const Divider(),
          
          _buildSectionHeader('Developer Options'),
          ListTile(
            title: const Text('Reset First Launch State'),
            subtitle: const Text('App will show onboarding on next launch'),
            trailing: const Icon(Icons.refresh, color: Colors.red),
            onTap: () {
              _resetFirstLaunchState();
            },
          ),
          const Divider(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          
                          final authService = Provider.of<AuthService>(context, listen: false);
                          await authService.logout();
                          
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', 
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Simplified Chinese'),
            _buildLanguageOption('Japanese'),
            _buildLanguageOption('Korean'),
          ],
        );
      },
    );
  }
  
  Widget _buildLanguageOption(String language) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Text(language),
    );
  }
  
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Theme'),
          children: [
            _buildThemeOption('Light Mode'),
            _buildThemeOption('Dark Mode'),
            _buildThemeOption('System Default'),
          ],
        );
      },
    );
  }
  
  Widget _buildThemeOption(String theme) {
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _selectedTheme = theme;
        });
        Navigator.pop(context);
      },
      child: Text(theme),
    );
  }
  
  Future<void> _resetFirstLaunchState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First launch state has been reset, please restart the app'),
          duration: Duration(seconds: 2),
        ),
      );
      
      debugPrint('First launch state has been reset to true');
    } catch (e) {
      debugPrint('Error resetting first launch state: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset failed, please try again later'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
