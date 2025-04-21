import 'package:flutter/material.dart';

class BreakthroughModePage extends StatefulWidget {
  const BreakthroughModePage({Key? key}) : super(key: key);

  @override
  State<BreakthroughModePage> createState() => _BreakthroughModePageState();
}

class _BreakthroughModePageState extends State<BreakthroughModePage> {
  final List<BreakthroughExercise> _exercises = [
    BreakthroughExercise(
      title: '经典瑜伽突破',
      description: '针对性提高瑜伽姿势的准确性和稳定性',
      difficulty: ExerciseDifficulty.medium,
      duration: const Duration(minutes: 15),
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
      requiredEquipment: ['瑜伽垫'],
      focusAreas: ['核心', '柔韧性', '平衡'],
    ),
    BreakthroughExercise(
      title: '深蹲极限挑战',
      description: '逐步纠正深蹲姿势，提高下肢力量',
      difficulty: ExerciseDifficulty.hard,
      duration: const Duration(minutes: 20),
      imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155',
      requiredEquipment: ['哑铃（可选）'],
      focusAreas: ['腿部力量', '核心稳定', '姿势校准'],
    ),
    BreakthroughExercise(
      title: '初学者姿势入门',
      description: '基础姿势练习，为进阶训练打好基础',
      difficulty: ExerciseDifficulty.easy,
      duration: const Duration(minutes: 10),
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
      requiredEquipment: [],
      focusAreas: ['基础姿势', '身体意识'],
    ),
    BreakthroughExercise(
      title: '肩颈放松突破',
      description: '针对办公族的肩颈紧张问题，提供有效缓解',
      difficulty: ExerciseDifficulty.medium,
      duration: const Duration(minutes: 12),
      imageUrl: 'https://images.unsplash.com/photo-1581009137042-c552e485697a',
      requiredEquipment: ['毛巾或弹力带'],
      focusAreas: ['肩颈放松', '姿势改善'],
    ),
  ];

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('突破模式'),
      ),
      body: _selectedIndex == -1
          ? _buildExerciseList()
          : _buildExerciseDetail(_exercises[_selectedIndex]),
    );
  }

  Widget _buildExerciseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '姿势突破训练',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '针对您的薄弱环节，提供专业指导和挑战，帮助您突破姿势瓶颈',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              return _buildExerciseCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(int index) {
    final exercise = _exercises[index];
    
    Color difficultyColor;
    String difficultyText;
    
    switch (exercise.difficulty) {
      case ExerciseDifficulty.easy:
        difficultyColor = Colors.green;
        difficultyText = '简单';
        break;
      case ExerciseDifficulty.medium:
        difficultyColor = Colors.orange;
        difficultyText = '中等';
        break;
      case ExerciseDifficulty.hard:
        difficultyColor = Colors.red;
        difficultyText = '困难';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Stack(
              children: [
                Image.network(
                  exercise.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      difficultyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 信息区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.duration.inMinutes} 分钟',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.focusAreas.join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
    );
  }

  Widget _buildExerciseDetail(BreakthroughExercise exercise) {
    Color difficultyColor;
    String difficultyText;
    
    switch (exercise.difficulty) {
      case ExerciseDifficulty.easy:
        difficultyColor = Colors.green;
        difficultyText = '简单';
        break;
      case ExerciseDifficulty.medium:
        difficultyColor = Colors.orange;
        difficultyText = '中等';
        break;
      case ExerciseDifficulty.hard:
        difficultyColor = Colors.red;
        difficultyText = '困难';
        break;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Stack(
            children: [
              Image.network(
                exercise.imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                left: 16,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = -1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    difficultyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                // 详细信息
                _buildDetailItem(
                  Icons.timer,
                  '时长',
                  '${exercise.duration.inMinutes} 分钟',
                ),
                _buildDetailItem(
                  Icons.fitness_center,
                  '重点区域',
                  exercise.focusAreas.join(', '),
                ),
                _buildDetailItem(
                  Icons.sports_gymnastics,
                  '所需装备',
                  exercise.requiredEquipment.isEmpty
                      ? '无'
                      : exercise.requiredEquipment.join(', '),
                ),
                const SizedBox(height: 24),
                const Text(
                  '挑战内容',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildChallengeStep(
                  1,
                  '姿势评估',
                  '系统将首先评估您当前的姿势水平，找出需要改善的地方。',
                ),
                _buildChallengeStep(
                  2,
                  '针对性训练',
                  '根据评估结果，提供针对性的训练动作和反馈。',
                ),
                _buildChallengeStep(
                  3,
                  '实时纠正',
                  '系统会实时监测您的动作，提供即时纠正指导。',
                ),
                _buildChallengeStep(
                  4,
                  '进步跟踪',
                  '记录您的训练进度，展示姿势改善情况。',
                ),
                const SizedBox(height: 32),
                // 开始按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 跳转到训练页面
                      Navigator.of(context).pushNamed('/pose_compare');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '开始挑战',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildChallengeStep(int step, String title, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

class BreakthroughExercise {
  final String title;
  final String description;
  final ExerciseDifficulty difficulty;
  final Duration duration;
  final String imageUrl;
  final List<String> requiredEquipment;
  final List<String> focusAreas;

  BreakthroughExercise({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.imageUrl,
    required this.requiredEquipment,
    required this.focusAreas,
  });
}
