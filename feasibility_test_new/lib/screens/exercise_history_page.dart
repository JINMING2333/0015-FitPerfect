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
      appBar: AppBar(
        title: const Text('Exercise History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyService.getExerciseHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load: ${snapshot.error}'),
            );
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text('No exercise records'),
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
                child: ListTile(
                  title: Text(record['exerciseName'] ?? 'Unknown Exercise'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}'),
                      Text('Score: ${score.toStringAsFixed(1)}'),
                      Text('Duration: ${(duration / 60).toStringAsFixed(1)} minutes'),
                      Text('Level: ${record['level']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
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
                          );

                          if (confirmed == true) {
                            await _historyService.deleteExerciseHistory(record['id']);
                            setState(() {}); // Refresh list
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 