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
  String _selectedLanguage = '简体中文';
  String _selectedTheme = '浅色模式';
  
  final List<String> _availableLanguages = [
    '简体中文',
    'English',
    '日本語',
    '한국어',
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
        _selectedLanguage = prefs.getString('selected_language') ?? '简体中文';
        _selectedTheme = prefs.getString('selected_theme') ?? '浅色模式';
      });
    } catch (e) {
      debugPrint('无法加载设置: $e');
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
        const SnackBar(content: Text('设置已保存')),
      );
    } catch (e) {
      debugPrint('无法保存设置: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存设置失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('通知设置'),
          SwitchListTile(
            title: const Text('接收通知'),
            subtitle: const Text('启用以接收训练提醒'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          
          _buildSectionHeader('应用设置'),
          ListTile(
            title: const Text('语言'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          ListTile(
            title: const Text('主题'),
            subtitle: Text(_selectedTheme),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showThemeDialog();
            },
          ),
          const Divider(),
          
          _buildSectionHeader('关于'),
          ListTile(
            title: const Text('应用版本'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('用户协议'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 显示用户协议
            },
          ),
          ListTile(
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // 显示隐私政策
            },
          ),
          const Divider(),
          
          // 添加开发选项
          _buildSectionHeader('开发选项'),
          ListTile(
            title: const Text('重置首次启动状态'),
            subtitle: const Text('应用将在下次启动时显示引导页'),
            trailing: const Icon(Icons.refresh, color: Colors.red),
            onTap: () {
              _resetFirstLaunchState();
            },
          ),
          const Divider(),
          
          // 底部按钮 - 退出账户
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                // 实现账户退出逻辑
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认退出'),
                    content: const Text('您确定要退出当前账户吗？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          
                          // 使用AuthService退出登录
                          final authService = Provider.of<AuthService>(context, listen: false);
                          await authService.logout();
                          
                          if (mounted) {
                            // 退出到登录页
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', 
                              (route) => false, // 清除所有路由历史
                            );
                          }
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('退出账户'),
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
          title: const Text('选择语言'),
          children: [
            _buildLanguageOption('简体中文'),
            _buildLanguageOption('English'),
            _buildLanguageOption('日本語'),
            _buildLanguageOption('한국어'),
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
          title: const Text('选择主题'),
          children: [
            _buildThemeOption('浅色模式'),
            _buildThemeOption('深色模式'),
            _buildThemeOption('跟随系统'),
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
  
  // 重置首次启动状态
  Future<void> _resetFirstLaunchState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('首次启动状态已重置，请重新启动应用'),
          duration: Duration(seconds: 2),
        ),
      );
      
      debugPrint('首次启动状态已重置为true');
    } catch (e) {
      debugPrint('重置首次启动状态错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('重置失败，请稍后再试'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
