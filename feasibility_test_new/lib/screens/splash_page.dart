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
  bool _isFirstLaunch = true; // 默认为首次启动

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

    // 检查是否是首次启动
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否存在first_launch键
      final bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
      
      debugPrint('应用状态: 首次启动=${isFirstLaunch}');
      
      setState(() {
        _isFirstLaunch = isFirstLaunch;
      });
    } catch (e) {
      debugPrint('SharedPreferences 错误: $e');
      setState(() {
        _isFirstLaunch = true; // 出错时默认为首次启动
      });
    }
  }

  // 按钮点击事件处理
  void _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = Provider.of<AuthService>(context, listen: false);
      
      debugPrint('导航到下一个屏幕: 首次启动=${_isFirstLaunch}, 已登录=${authService.isLoggedIn}');
      
      if (_isFirstLaunch) {
        // 如果是首次启动，标记非首次启动并跳转到引导页
        debugPrint('保存首次启动状态为false');
        await prefs.setBool('first_launch', false);
        
        if (mounted) {
          debugPrint('导航到: /onboarding');
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      } else {
        // 非首次启动，根据登录状态决定跳转
        if (authService.isLoggedIn) {
          // 已登录，跳转到主页
          if (mounted) {
            debugPrint('导航到: /home (已登录)');
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // 未登录，跳转到登录页
          if (mounted) {
            debugPrint('导航到: /login (未登录)');
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      debugPrint('导航错误: $e');
      // 出错时默认进入引导页
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
          color: Color(0xFFF8E8A7), // 黄色背景
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部留白
              const SizedBox(height: 60),
              
              // 主要内容 - 白色卡片包含运动图像
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
                      // 注意：您需要将这个图片放在assets/images文件夹中
                      // 也可以使用其他合适的运动图片
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          // 如果图片未找到，显示替代图标
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
                                    '健康运动',
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
              
              // 标题和副标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  children: [
                    // 应用主标题 - 运动时间
                    FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        'Time to exercise',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32), // 深绿色
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 应用口号 - 实时反馈
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
                    // 添加状态显示，便于调试
                    const SizedBox(height: 10),
                    Text(
                      '状态: ${_isFirstLaunch ? "首次启动" : "非首次启动"}, ${authService.isLoggedIn ? "已登录" : "未登录"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部按钮 - 开始使用
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
                        backgroundColor: const Color(0xFF2E7D32), // 深绿色
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
