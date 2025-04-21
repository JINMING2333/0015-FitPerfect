import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TrainingRecord> _mockRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateMockData();
  }

  void _generateMockData() {
    // 生成模拟数据
    final now = DateTime.now();
    
    // 今天的记录
    _mockRecords.add(
      TrainingRecord(
        id: '1',
        type: TrainingType.standard,
        name: '基础瑜伽姿势',
        date: now,
        duration: const Duration(minutes: 15),
        score: 85,
        improvements: ['肩部下沉需要改进', '背部挺直做得不错'],
      ),
    );
    
    // 昨天的记录
    _mockRecords.add(
      TrainingRecord(
        id: '2',
        type: TrainingType.challenge,
        name: '高难度瑜伽挑战',
        date: now.subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 20),
        score: 75,
        improvements: ['平衡性需要加强', '呼吸节奏保持稳定'],
      ),
    );
    
    // 更早的记录
    _mockRecords.add(
      TrainingRecord(
        id: '3',
        type: TrainingType.standard,
        name: '初级瑜伽训练',
        date: now.subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 10),
        score: 70,
        improvements: ['姿势保持时间需要延长', '动作流畅度有所提高'],
      ),
    );
    
    _mockRecords.add(
      TrainingRecord(
        id: '4',
        type: TrainingType.custom,
        name: '自定义健身动作',
        date: now.subtract(const Duration(days: 5)),
        duration: const Duration(minutes: 25),
        score: 80,
        improvements: ['动作幅度可以更大', '核心稳定性很好'],
      ),
    );
    
    _mockRecords.add(
      TrainingRecord(
        id: '5',
        type: TrainingType.challenge,
        name: '平衡挑战',
        date: now.subtract(const Duration(days: 7)),
        duration: const Duration(minutes: 12),
        score: 65,
        improvements: ['需要更多练习来提高平衡性', '姿势准确度有待提高'],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练历史'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '本周'),
            Tab(text: '本月'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrainingList(_mockRecords),
          _buildTrainingList(_mockRecords.where(
            (record) => record.date.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          ).toList()),
          _buildTrainingList(_mockRecords.where(
            (record) => record.date.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          ).toList()),
        ],
      ),
    );
  }

  Widget _buildTrainingList(List<TrainingRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          '暂无训练记录',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildTrainingCard(record);
      },
    );
  }

  Widget _buildTrainingCard(TrainingRecord record) {
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    final scoreColor = record.score >= 80
        ? Colors.green
        : (record.score >= 60 ? Colors.orange : Colors.red);

    IconData typeIcon;
    Color typeColor;

    switch (record.type) {
      case TrainingType.standard:
        typeIcon = Icons.fitness_center;
        typeColor = Colors.blue;
        break;
      case TrainingType.challenge:
        typeIcon = Icons.emoji_events;
        typeColor = Colors.orange;
        break;
      case TrainingType.custom:
        typeIcon = Icons.create;
        typeColor = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // TODO: 查看详细记录
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, color: typeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '得分: ${record.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateFormatter.format(record.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${record.duration.inMinutes} 分钟',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '改进建议:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...record.improvements.map((improvement) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            improvement,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: 查看详细分析
                  },
                  child: const Text('查看详细分析'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum TrainingType {
  standard,   // 标准训练
  challenge,  // 挑战模式
  custom,     // 自定义训练
}

class TrainingRecord {
  final String id;
  final String name;
  final TrainingType type;
  final DateTime date;
  final Duration duration;
  final int score;
  final List<String> improvements;

  TrainingRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.duration,
    required this.score,
    required this.improvements,
  });
}
