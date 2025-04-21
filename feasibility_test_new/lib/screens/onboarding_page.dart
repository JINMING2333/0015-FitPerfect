import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: '实时姿势评估',
      description: '通过AI技术实时分析您的运动姿势，提供即时反馈。',
      icon: Icons.camera_alt,
      color: Colors.blue,
    ),
    OnboardingItem(
      title: '标准动作对比',
      description: '与专业标准姿势进行对比，找出需要改进的地方。',
      icon: Icons.compare_arrows,
      color: Colors.green,
    ),
    OnboardingItem(
      title: '个性化建议',
      description: '根据您的表现提供个性化的改进建议和训练计划。',
      icon: Icons.person,
      color: Colors.orange,
    ),
    OnboardingItem(
      title: '进步追踪',
      description: '记录您的训练历史，查看进步情况，保持动力。',
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 页面指示器
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? _items[index].color
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  // 按钮区域
                  _currentPage < _items.length - 1
                      ? ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _items[_currentPage].color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('下一步'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            // 引导页结束后跳转到登录页面
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _items[_currentPage].color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('开始使用'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 120,
            color: item.color,
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
