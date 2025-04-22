import 'package:flutter/material.dart';

class BreakthroughModePage extends StatefulWidget {
  final String? selectedSport;
  
  const BreakthroughModePage({
    Key? key, 
    this.selectedSport,
  }) : super(key: key);

  @override
  State<BreakthroughModePage> createState() => _BreakthroughModePageState();
}

class _BreakthroughModePageState extends State<BreakthroughModePage> {
  // 总关卡数
  final int _totalLevels = 9;
  
  // 当前进度
  int _currentProgress = 3;
  
  // 每个关卡的状态
  final List<LevelData> _levels = [
    // 第一行 - 已通关
    LevelData(
      number: 1,
      state: LevelState.completed,
      reward: RewardType.sunflower,
    ),
    LevelData(
      number: 2,
      state: LevelState.completed,
      reward: RewardType.sunflower,
    ),
    LevelData(
      number: 3,
      state: LevelState.completed,
      reward: RewardType.sunflower,
    ),
    
    // 第二行
    LevelData(
      number: 4,
      state: LevelState.current,
    ),
    LevelData(
      number: 5,
      state: LevelState.locked,
    ),
    LevelData(
      number: 6,
      state: LevelState.locked,
    ),
    
    // 第三行
    LevelData(
      number: 7,
      state: LevelState.locked,
    ),
    LevelData(
      number: 8,
      state: LevelState.locked,
    ),
    LevelData(
      number: 9,
      state: LevelState.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 从路由参数中获取selectedSport
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String? sportName = routeArgs is String ? routeArgs : widget.selectedSport;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F8E6), Color(0xFFE0F1D8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(sportName),
              SizedBox(height: 20),
              _buildProgressBar(),
              SizedBox(height: 20),
              Expanded(
                child: _buildLevelGrid(),
              ),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader([String? sportName]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              sportName != null ? '${sportName} Breakthrough Mode' : 'Breakthrough Mode',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 48), // 保持标题居中的平衡
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 猫咪图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // 进度条和文字
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $_currentProgress completed',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '$_currentProgress/$_totalLevels',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Stack(
                        children: [
                          // 背景条
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // 进度
                          FractionallySizedBox(
                            widthFactor: _currentProgress / _totalLevels,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.4),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Challenge Levels',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: List.generate(
                _levels.length,
                (index) => _buildLevelItem(_levels[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelItem(LevelData level) {
    Color backgroundColor;
    Color borderColor;
    Widget icon;
    String statusText;
    
    switch (level.state) {
      case LevelState.completed:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        statusText = 'Completed';
        icon = Image.asset(
          'assets/images/sunflower.png',
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.local_florist,
            color: Colors.yellow,
            size: 50,
          ),
        );
        break;
      case LevelState.current:
        backgroundColor = Colors.amber.shade50;
        borderColor = Colors.amber;
        statusText = 'In Challenge';
        icon = Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: 30,
            ),
          ),
        );
        break;
      case LevelState.locked:
        backgroundColor = Color(0xFFF5F5DC); // 米白色
        borderColor = Colors.grey.shade400;
        statusText = 'Locked';
        icon = Icon(
          Icons.lock,
          color: Colors.grey.shade500,
          size: 40,
        );
        break;
    }

    return GestureDetector(
      onTap: () => _onLevelTap(level),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 关卡号
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: level.state == LevelState.locked 
                    ? Colors.grey.shade300
                    : borderColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${level.number}',
                  style: TextStyle(
                    color: level.state == LevelState.locked 
                        ? Colors.grey.shade700
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // 图标
            icon,
            
            SizedBox(height: 12),
            
            // 状态文本
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: level.state == LevelState.locked 
                    ? Colors.grey.shade600
                    : borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () {
            if (_levels.any((level) => level.state == LevelState.current)) {
              // 找到当前挑战的关卡
              LevelData currentLevel = _levels.firstWhere(
                (level) => level.state == LevelState.current
              );
              _onLevelTap(currentLevel);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            minimumSize: Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'Continue to Current Challenge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _onLevelTap(LevelData level) {
    switch (level.state) {
      case LevelState.completed:
        _showCompletedLevelDialog(level);
        break;
      case LevelState.current:
        _showCurrentLevelDialog(level);
        break;
      case LevelState.locked:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complete previous levels first to unlock this level'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        );
        break;
    }
  }

  void _showCompletedLevelDialog(LevelData level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level ${level.number} - Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Congratulations! You\'ve completed this level successfully.'),
              SizedBox(height: 16),
              Text('Error Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildMistakeItem('Posture Angle', 'Right arm angle was 15° off'),
              _buildMistakeItem('Stability', 'Minor wobbling on support leg'),
              _buildMistakeItem('Motion Completion', 'Squat depth didn\'t reach standard'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pose_compare');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Try Again'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void _showCurrentLevelDialog(LevelData level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level ${level.number} - Start Challenge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Previous attempt error summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildMistakeItem('Posture Angle', 'Body tilt exceeded 10°'),
              _buildMistakeItem('Balance', 'Hold time less than 5 seconds'),
              SizedBox(height: 16),
              Text('Ready to start today\'s challenge?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pose_compare');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: Text('Start Challenge'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  Widget _buildMistakeItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateProgress() {
    int completedCount = _levels.where((level) => level.state == LevelState.completed).length;
    setState(() {
      _currentProgress = completedCount;
    });
  }
}

// 关卡状态枚举
enum LevelState {
  completed,  // 已通关
  current,    // 当前挑战
  locked,     // 未解锁
}

// 奖励类型枚举
enum RewardType {
  sunflower,  // 向日葵
}

// 关卡数据类
class LevelData {
  final int number;
  final LevelState state;
  final RewardType? reward;
  
  LevelData({
    required this.number,
    required this.state,
    this.reward,
  });
}

// 练习数据模型 - 保留以便未来扩展
class BreakthroughExercise {
  final String title;
  final String description;
  final ExerciseDifficulty difficulty;
  final Duration duration;
  final String imageUrl;
  final List<String> requiredEquipment;
  final List<String> focusAreas;
  final String category;

  BreakthroughExercise({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.imageUrl,
    required this.requiredEquipment,
    required this.focusAreas,
    required this.category,
  });
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}
