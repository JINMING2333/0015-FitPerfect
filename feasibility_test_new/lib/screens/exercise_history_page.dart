import 'package:flutter/material.dart';
import '../services/exercise_history_service.dart';
import 'package:intl/intl.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({Key? key}) : super(key: key);

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  final ExerciseHistoryService _historyService = ExerciseHistoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Exercise History'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyService.getExerciseHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            );
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercise records',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final timestamp = DateTime.parse(record['timestamp'] ?? DateTime.now().toString());
              final score = record['score'] as double;
              final duration = record['duration'] as int;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    record['exerciseName'] ?? 'Unknown Exercise',
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.access_time,
                        'Time: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}',
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.star,
                        'Score: ${score.toStringAsFixed(1)}',
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.timer,
                        'Duration: ${(duration / 60).toStringAsFixed(1)} minutes',
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.trending_up,
                        'Level: ${record['level']}',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[400],
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            'Confirm Delete',
                            style: TextStyle(
                              color: Colors.grey[900],
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete this record?',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _historyService.deleteExerciseHistory(record['id']);
                        setState(() {}); // Refresh list
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 