import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataService = Provider.of<UserDataService>(context);
    final authService = Provider.of<AuthService>(context);
    
    // 如果用户未登录，显示提示登录界面
    if (!authService.isLoggedIn) {
      return _buildLoginPrompt();
    }

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
          _buildFirestoreTrainingList(userDataService, null),
          _buildFirestoreTrainingList(
            userDataService, 
            DateTime.now().subtract(const Duration(days: 7))
          ),
          _buildFirestoreTrainingList(
            userDataService, 
            DateTime.now().subtract(const Duration(days: 30))
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练历史'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              '请登录以查看您的训练历史',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirestoreTrainingList(UserDataService userDataService, DateTime? startDate) {
    return StreamBuilder<QuerySnapshot>(
      stream: userDataService.getTrainingHistory(),
      builder: (context, snapshot) {
        // 显示加载指示器
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // 显示错误信息
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '加载失败: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        // 数据为空
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
        
        // 获取所有训练记录
        List<DocumentSnapshot> records = snapshot.data!.docs;
        
        // 如果有开始日期，过滤记录
        if (startDate != null) {
          records = records.where((record) {
            Timestamp timestamp = record['timestamp'] as Timestamp;
            return timestamp.toDate().isAfter(startDate);
          }).toList();
        }
        
        // 再次检查过滤后是否为空
        if (records.isEmpty) {
          return const Center(
            child: Text(
              '该时间段内暂无训练记录',
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
            return _buildFirestoreTrainingCard(record);
          },
        );
      },
    );
  }

  Widget _buildFirestoreTrainingCard(DocumentSnapshot record) {
    final data = record.data() as Map<String, dynamic>;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    
    // 获取记录中的数据，使用默认值避免空值
    final String exercise = data['exercise'] ?? '未知训练';
    final int duration = data['duration'] ?? 0;
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = data['imageUrl'] ?? '';
    
    // 获取时间戳并转换为日期
    final DateTime date = data['timestamp'] is Timestamp 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.now();
    
    // 确定分数颜色
    final scoreColor = score >= 80
        ? Colors.green
        : (score >= 60 ? Colors.orange : Colors.red);
    
    // 确定训练类型图标
    IconData typeIcon = Icons.fitness_center;
    Color typeColor = Colors.blue;
    
    if (exercise.toLowerCase().contains('挑战')) {
      typeIcon = Icons.emoji_events;
      typeColor = Colors.orange;
    } else if (exercise.toLowerCase().contains('自定义')) {
      typeIcon = Icons.create;
      typeColor = Colors.purple;
    }
    
    // 改进建议列表，如果存在
    List<String> improvements = [];
    if (data['improvements'] is List) {
      improvements = List<String>.from(data['improvements']);
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // 查看详细记录
          _showTrainingDetails(record);
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
                      exercise,
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
                      '得分: ${score.toStringAsFixed(1)}',
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
                    dateFormatter.format(date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$duration 分钟',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              // 如果有图片，显示图片预览
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              
              // 如果有改进建议，显示建议
              if (improvements.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  '改进建议:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ...improvements.map((improvement) => Padding(
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
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTrainingDetails(DocumentSnapshot record) {
    final data = record.data() as Map<String, dynamic>;
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
    
    final String exercise = data['exercise'] ?? '未知训练';
    final int duration = data['duration'] ?? 0;
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = data['imageUrl'] ?? '';
    
    final DateTime date = data['timestamp'] is Timestamp 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('训练时间: ${dateFormatter.format(date)}'),
              Text('训练时长: $duration 分钟'),
              Text('训练得分: ${score.toStringAsFixed(1)}'),
              
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('训练截图:'),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Text('图片加载失败')),
                  ),
                ),
              ],
              
              if (data['improvements'] is List) ...[
                const SizedBox(height: 16),
                const Text('改进建议:'),
                const SizedBox(height: 8),
                ...List<String>.from(data['improvements']).map(
                  (improvement) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(improvement)),
                      ],
                    ),
                  ),
                ),
              ],
              
              // 显示任何其他可能的记录数据
              const SizedBox(height: 16),
              const Text('其他数据:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...data.entries
                  .where((entry) => !['exercise', 'duration', 'score', 'imageUrl', 'timestamp', 'improvements']
                      .contains(entry.key))
                  .map((entry) => Text('${entry.key}: ${entry.value}')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              // 确认删除
              Navigator.pop(context);
              _confirmDeleteRecord(record.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除记录'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecord(String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条训练记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userDataService = Provider.of<UserDataService>(context, listen: false);
              final success = await userDataService.deleteTrainingRecord(recordId);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('记录已删除')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除失败，请稍后再试')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// TrainingType枚举，用于分类训练类型
enum TrainingType {
  standard,  // 标准训练
  challenge, // 挑战
  custom,    // 自定义
}
