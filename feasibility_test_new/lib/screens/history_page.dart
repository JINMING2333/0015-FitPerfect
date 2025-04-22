// lib/screens/history_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // 选中的时间范围
  String _selectedTimeRange = '全部';
  List<String> _timeRanges = ['全部', '本周', '本月'];
  
  // 选中的训练类型
  String _selectedType = '全部类型';
  List<String> _exerciseTypes = ['全部类型', '标准训练', '挑战模式', '自定义训练'];
  
  // 选中的排序方式
  String _sortBy = '日期';
  List<String> _sortOptions = ['日期', '分数', '时长'];
  
  @override
  Widget build(BuildContext context) {
    final userDataService = Provider.of<UserDataService>(context);
    final authService = Provider.of<AuthService>(context);
    
    // 如果用户未登录，显示提示登录界面
    if (!authService.isLoggedIn) {
      return _buildLoginPrompt();
    }

    // 确定日期过滤器
    DateTime? startDate;
    if (_selectedTimeRange == '本周') {
      startDate = DateTime.now().subtract(const Duration(days: 7));
    } else if (_selectedTimeRange == '本月') {
      startDate = DateTime.now().subtract(const Duration(days: 30));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题和统计信息
            _buildHeader(userDataService),
            
            // 筛选选项
            _buildFilterBar(),
            
            // 视觉反馈集锦
            Expanded(
              child: _buildFeedbackGallery(userDataService, startDate),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showVisualizationOptions();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.insights),
      ),
    );
  }
  
  Widget _buildHeader(UserDataService userDataService) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '训练视觉反馈',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // 设置选项
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '集锦展示你的训练姿势和反馈',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // 统计卡片
          FutureBuilder<Map<String, dynamic>>(
            future: userDataService.getUserStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final stats = snapshot.data!;
              final totalTrainings = stats['totalTrainings'] ?? 0;
              final totalDuration = stats['totalDuration'] ?? 0;
              final averageScore = stats['averageScore'] ?? 0.0;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    '总次数',
                    '$totalTrainings',
                    Colors.blue,
                  ),
                  _buildStatCard(
                    '总时长',
                    '${totalDuration}分钟',
                    Colors.green,
                  ),
                  _buildStatCard(
                    '平均分',
                    averageScore.toStringAsFixed(1),
                    Colors.orange,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        children: [
          // 时间和类型过滤器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 时间范围选择
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedTimeRange,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _timeRanges.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimeRange = newValue;
                        });
                      }
                    },
                  ),
                ),
                
                // 类型选择
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _exerciseTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                  ),
                ),
                
                // 排序方式
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('排序: '),
                      DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _sortOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _sortBy = newValue;
                            });
                          }
                        },
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
  
  Widget _buildFeedbackGallery(UserDataService userDataService, DateTime? startDate) {
    return StreamBuilder<QuerySnapshot>(
      stream: userDataService.getTrainingHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '加载失败: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }
        
        // 获取所有训练记录
        List<DocumentSnapshot> records = snapshot.data!.docs;
        
        // 筛选时间范围
        if (startDate != null) {
          records = records.where((record) {
            Timestamp timestamp = record['timestamp'] as Timestamp;
            return timestamp.toDate().isAfter(startDate);
          }).toList();
        }
        
        // 筛选训练类型
        if (_selectedType != '全部类型') {
          records = records.where((record) {
            final data = record.data() as Map<String, dynamic>;
            final String exercise = data['exercise'] ?? '';
            
            if (_selectedType == '标准训练') {
              return !exercise.toLowerCase().contains('挑战') && 
                     !exercise.toLowerCase().contains('自定义');
            } else if (_selectedType == '挑战模式') {
              return exercise.toLowerCase().contains('挑战');
            } else if (_selectedType == '自定义训练') {
              return exercise.toLowerCase().contains('自定义');
            }
            return true;
          }).toList();
        }
        
        // 应用排序
        records.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          
          if (_sortBy == '日期') {
            final timeA = dataA['timestamp'] as Timestamp;
            final timeB = dataB['timestamp'] as Timestamp;
            return timeB.compareTo(timeA); // 降序排列，最新的在前面
          } else if (_sortBy == '分数') {
            final scoreA = (dataA['score'] as num?)?.toDouble() ?? 0.0;
            final scoreB = (dataB['score'] as num?)?.toDouble() ?? 0.0;
            return scoreB.compareTo(scoreA); // 降序排列，高分在前
          } else if (_sortBy == '时长') {
            final durationA = dataA['duration'] as int? ?? 0;
            final durationB = dataB['duration'] as int? ?? 0;
            return durationB.compareTo(durationA); // 降序排列，时长长的在前
          }
          return 0;
        });
        
        if (records.isEmpty) {
          return _buildEmptyState();
        }
        
        // 以网格形式显示视觉反馈
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildFeedbackCard(records[index]);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildFeedbackCard(DocumentSnapshot record) {
    final data = record.data() as Map<String, dynamic>;
    
    // 获取记录数据
    final String exercise = data['exercise'] ?? '未知训练';
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = data['imageUrl'] ?? '';
    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final DateTime date = timestamp.toDate();
    final String formattedDate = DateFormat('MM-dd HH:mm').format(date);
    
    // 确定分数颜色
    final Color scoreColor = score >= 80 
        ? Colors.green 
        : (score >= 60 ? Colors.orange : Colors.red);
    
    // 确定训练图标
    IconData exerciseIcon = Icons.fitness_center;
    if (exercise.toLowerCase().contains('挑战')) {
      exerciseIcon = Icons.emoji_events;
    } else if (exercise.toLowerCase().contains('自定义')) {
      exerciseIcon = Icons.create;
    }
    
    return InkWell(
      onTap: () => _showFeedbackDetails(record),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 训练图片
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            
            // 训练信息
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 训练名称和图标
                  Row(
                    children: [
                      Icon(exerciseIcon, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          exercise,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // 日期
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 分数
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 14, color: scoreColor),
                        const SizedBox(width: 4),
                        Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无训练记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '开始训练，记录你的姿势反馈',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.fitness_center),
            label: const Text('开始训练'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/training');
            },
          ),
        ],
      ),
    );
  }
  
  void _showVisualizationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '视觉反馈选项',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildVisualizationOption(
              icon: Icons.grid_on,
              title: '网格视图',
              subtitle: '以网格形式查看训练记录',
              onTap: () {
                Navigator.pop(context);
                // 切换为网格视图
              },
            ),
            const Divider(),
            _buildVisualizationOption(
              icon: Icons.timeline,
              title: '进度视图',
              subtitle: '查看训练进度和改进情况',
              onTap: () {
                Navigator.pop(context);
                // 切换为进度视图
              },
            ),
            const Divider(),
            _buildVisualizationOption(
              icon: Icons.video_collection,
              title: '动作集锦',
              subtitle: '查看动作视频集锦',
              onTap: () {
                Navigator.pop(context);
                // 切换为视频集锦视图
              },
            ),
            const Divider(),
            _buildVisualizationOption(
              icon: Icons.compare,
              title: '对比分析',
              subtitle: '对比不同时间的训练效果',
              onTap: () {
                Navigator.pop(context);
                // 切换为对比分析视图
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVisualizationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
  
  void _showFeedbackDetails(DocumentSnapshot record) {
    final data = record.data() as Map<String, dynamic>;
    
    // 获取记录数据
    final String exercise = data['exercise'] ?? '未知训练';
    final int duration = data['duration'] ?? 0;
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = data['imageUrl'] ?? '';
    
    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final DateTime date = timestamp.toDate();
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    
    // 改进建议
    List<String> improvements = [];
    if (data['improvements'] is List) {
      improvements = List<String>.from(data['improvements']);
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部图片
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            
            // 内容
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 基本信息
                    _buildInfoRow(Icons.calendar_today, '日期：$formattedDate'),
                    _buildInfoRow(Icons.timer_outlined, '时长：$duration 分钟'),
                    _buildInfoRow(Icons.star_outline, '得分：${score.toStringAsFixed(1)}'),
                    
                    // 改进建议
                    if (improvements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '改进建议',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...improvements.map((improvement) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                    ],
                    
                    // 其他数据
                    const SizedBox(height: 16),
                    const Text(
                      '详细数据',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.entries
                        .where((entry) => !['exercise', 'duration', 'score', 'imageUrl', 'timestamp', 'improvements']
                            .contains(entry.key))
                        .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${entry.key}: ${entry.value}'),
                        )),
                  ],
                ),
              ),
            ),
            
            // 按钮区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteRecord(record.id);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('分享'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      // 分享功能
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
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
}