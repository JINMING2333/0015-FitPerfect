// lib/screens/history_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/exercise_history_service.dart';
import '../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Selected time range
  String _selectedTimeRange = 'All';
  List<String> _timeRanges = ['All', 'This Week', 'This Month'];
  
  // Selected exercise type
  String _selectedType = 'All Types';
  List<String> _exerciseTypes = ['All Types', 'Standard Training', 'Challenge Mode', 'Custom Training'];
  
  // Selected sort method
  String _sortBy = 'Date';
  List<String> _sortOptions = ['Date', 'Score', 'Duration'];

  final ExerciseHistoryService _historyService = ExerciseHistoryService();
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // If user is not logged in, show login prompt
    if (!authService.isLoggedIn) {
      return _buildLoginPrompt();
    }

    // Determine date filter
    DateTime? startDate;
    if (_selectedTimeRange == 'This Week') {
      startDate = DateTime.now().subtract(const Duration(days: 7));
    } else if (_selectedTimeRange == 'This Month') {
      startDate = DateTime.now().subtract(const Duration(days: 30));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header title and statistics
            _buildHeader(),
            
            // Filter options
            _buildFilterBar(),
            
            // Training history list
            Expanded(
              child: _buildHistoryList(startDate),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
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
                'Training History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // Settings options
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'View your training records and progress',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
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
                      const Text('Sort: '),
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
  
  Widget _buildHistoryList(DateTime? startDate) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyService.getExerciseHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }
        
        // 获取所有训练记录
        List<Map<String, dynamic>> records = snapshot.data!;
        
        // 筛选时间范围
        if (startDate != null) {
          records = records.where((record) {
            final timestamp = DateTime.parse(record['timestamp'] as String);
            return timestamp.isAfter(startDate);
          }).toList();
        }
        
        // 筛选训练类型
        if (_selectedType != 'All Types') {
          records = records.where((record) {
            final String exerciseName = record['exerciseName'] ?? '';
            
            if (_selectedType == 'Standard Training') {
              return !exerciseName.toLowerCase().contains('challenge') && 
                     !exerciseName.toLowerCase().contains('custom');
            } else if (_selectedType == 'Challenge Mode') {
              return exerciseName.toLowerCase().contains('challenge');
            } else if (_selectedType == 'Custom Training') {
              return exerciseName.toLowerCase().contains('custom');
            }
            return true;
          }).toList();
        }
        
        // 应用排序
        records.sort((a, b) {
          if (_sortBy == 'Date') {
            final timeA = DateTime.parse(a['timestamp'] as String);
            final timeB = DateTime.parse(b['timestamp'] as String);
            return timeB.compareTo(timeA);
          } else if (_sortBy == 'Score') {
            final scoreA = (a['score'] as num?)?.toDouble() ?? 0.0;
            final scoreB = (b['score'] as num?)?.toDouble() ?? 0.0;
            return scoreB.compareTo(scoreA);
          } else if (_sortBy == 'Duration') {
            final durationA = a['duration'] as int? ?? 0;
            final durationB = b['duration'] as int? ?? 0;
            return durationB.compareTo(durationA);
          }
          return 0;
        });
        
        if (records.isEmpty) {
          return _buildEmptyState();
        }
        
        // 以网格形式显示训练记录
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
              return _buildHistoryCard(records[index]);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildHistoryCard(Map<String, dynamic> record) {
    final String exerciseName = record['exerciseName'] ?? 'Unknown Training';
    final double score = (record['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = record['imageUrl'] ?? '';
    final DateTime date = DateTime.parse(record['timestamp'] as String);
    final String formattedDate = DateFormat('MM-dd HH:mm').format(date);
    
    // 确定分数颜色
    final Color scoreColor = score >= 85 
        ? Colors.green 
        : (score >= 70 ? Colors.yellow : Colors.orange);
    
    // 确定训练图标
    IconData exerciseIcon = Icons.fitness_center;
    if (exerciseName.toLowerCase().contains('challenge')) {
      exerciseIcon = Icons.emoji_events;
    } else if (exerciseName.toLowerCase().contains('custom')) {
      exerciseIcon = Icons.create;
    }
    
    return InkWell(
      onTap: () => _showHistoryDetails(record),
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
                          exerciseName,
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
  
  void _showHistoryDetails(Map<String, dynamic> record) {
    final String exerciseName = record['exerciseName'] ?? 'Unknown Training';
    final int duration = record['duration'] as int? ?? 0;
    final double score = (record['score'] as num?)?.toDouble() ?? 0.0;
    final String imageUrl = record['imageUrl'] ?? '';
    final DateTime date = DateTime.parse(record['timestamp'] as String);
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    
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
                      exerciseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 基本信息
                    _buildInfoRow(Icons.calendar_today, 'Date: $formattedDate'),
                    _buildInfoRow(Icons.timer_outlined, 'Duration: $duration minutes'),
                    _buildInfoRow(Icons.star_outline, 'Score: ${score.toStringAsFixed(1)}'),
                    
                    // 其他数据
                    const SizedBox(height: 16),
                    const Text(
                      'Detailed Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...record.entries
                        .where((entry) => !['exerciseName', 'duration', 'score', 'imageUrl', 'timestamp']
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
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteRecord(record['id'] as String);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((value) async {
      if (value == true) {
        final success = await _historyService.deleteExerciseHistory(recordId);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted')),
          );
          setState(() {}); // Refresh list
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete, please try again later')),
          );
        }
      }
    });
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No training records yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete a training session to see your records here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training History'),
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
              'Please log in to view your training history',
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
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}