import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ExerciseHistoryService {
  static Database? _database;
  static const String tableName = 'exercise_history';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'exercise_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            exerciseName TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            score REAL NOT NULL,
            duration INTEGER NOT NULL,
            level TEXT NOT NULL,
            imageUrl TEXT,
            additionalData TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveExerciseHistory({
    required String exerciseId,
    required String exerciseName,
    required int duration,
    required double score,
    required String imageUrl,
    required String level,
    required Map<String, dynamic> additionalData,
    required String timestamp,
  }) async {
    final db = await database;
    await db.insert(
      tableName,
      {
        'id': exerciseId,
        'exerciseName': exerciseName,
        'timestamp': timestamp,
        'score': score,
        'duration': duration,
        'level': level,
        'imageUrl': imageUrl,
        'additionalData': jsonEncode(additionalData),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );

    return maps.map((record) {
      final additionalData = jsonDecode(record['additionalData'] as String) as Map<String, dynamic>;
      return <String, dynamic>{
        'id': record['id'],
        'exerciseName': record['exerciseName'],
        'timestamp': record['timestamp'],
        'score': record['score'],
        'duration': record['duration'],
        'level': record['level'],
        'imageUrl': record['imageUrl'],
        ...additionalData,
      };
    }).toList();
  }

  Future<void> deleteExerciseHistory(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllHistory() async {
    final db = await database;
    await db.delete(tableName);
  }
} 