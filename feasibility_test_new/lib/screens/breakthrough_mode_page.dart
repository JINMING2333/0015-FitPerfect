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
  int _currentProgress = 4;
  
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
          color: Color(0xFFE0F1D8), // 浅绿色背景
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(sportName),
              Expanded(
                child: _buildLevelGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader([String? sportName]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // 返回按钮和标题
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  sportName != null ? '${sportName} 闯关模式' : 'Let\'s play games~',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 48), // 保持标题居中的平衡
            ],
          ),
          
          // 进度条
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.brown[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 左侧黑猫头像
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                
                // 中间标题和进度条
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '天卡进度',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Stack(
                          children: [
                            // 背景条
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.brown[500],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // 进度
                            FractionallySizedBox(
                              widthFactor: _currentProgress / _totalLevels,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFD54F),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          '$_currentProgress / $_totalLevels',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 右侧宝箱
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.brown[600],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: Color(0xFFFFD54F),
                    size: 20,
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
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(
          _levels.length,
          (index) => _buildLevelItem(_levels[index]),
        ),
      ),
    );
  }

  Widget _buildLevelItem(LevelData level) {
    Color backgroundColor;
    Widget icon;
    bool showLock = false;
    
    switch (level.state) {
      case LevelState.completed:
        backgroundColor = Colors.green;
        icon = Image.asset(
          'assets/images/sunflower.png',
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.local_florist,
            color: Colors.yellow,
            size: 40,
          ),
        );
        break;
      case LevelState.current:
        backgroundColor = Colors.amber.shade200;
        icon = Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: 18,
            ),
          ),
        );
        break;
      case LevelState.locked:
        backgroundColor = Color(0xFFF5F5DC); // 米白色
        icon = Container();
        showLock = true;
        break;
    }

    return GestureDetector(
      onTap: () => _onLevelTap(level),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 关卡号
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: level.state == LevelState.locked 
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${level.number}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            // 奖励或角色
            Center(
              child: icon,
            ),
            
            // 锁图标
            if (showLock)
              Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 28,
                ),
              ),
          ],
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
          SnackBar(content: Text('请先完成前面的关卡'))
        );
        break;
    }
  }

  void _showCompletedLevelDialog(LevelData level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('第${level.number}关 - 已通关'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('恭喜您已完成本关卡！'),
              SizedBox(height: 16),
              Text('错误集锦：'),
              SizedBox(height: 8),
              _buildMistakeItem('姿势角度偏差', '右手抬高角度不足15°'),
              _buildMistakeItem('姿势稳定性', '支撑腿轻微晃动'),
              _buildMistakeItem('动作完成度', '深蹲未达到标准深度'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pose_compare');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('重新挑战'),
            ),
          ],
        );
      },
    );
  }

  void _showCurrentLevelDialog(LevelData level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('第${level.number}关 - 开始挑战'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('上次挑战的错误集锦：'),
              SizedBox(height: 8),
              _buildMistakeItem('姿势角度偏差', '身体倾斜超过10°'),
              _buildMistakeItem('平衡性', '保持时间不足5秒'),
              SizedBox(height: 16),
              Text('准备好开始今天的挑战了吗？'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pose_compare');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: Text('开始挑战'),
            ),
          ],
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
