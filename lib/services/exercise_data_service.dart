import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ExerciseDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 保存单次运动记录
  Future<void> saveExerciseRecord({
    required String exerciseId,
    required String exerciseName,
    required int duration,
    required double score,
    required String imageUrl,
    required int level,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ 保存失败：用户未登录');
        throw Exception('User not logged in');
      }

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      
      debugPrint('开始保存运动记录...');
      debugPrint('用户ID: ${user.uid}');
      debugPrint('运动ID: $exerciseId');
      debugPrint('运动名称: $exerciseName');
      debugPrint('时长: $duration');
      debugPrint('得分: $score');

      // 保存详细记录
      final recordData = {
        'userId': user.uid,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'duration': duration,
        'score': score,
        'imageUrl': imageUrl,
        'level': level,
        'additionalData': additionalData,
        'timestamp': FieldValue.serverTimestamp(),
        'date': date,
      };

      debugPrint('准备保存到 exercise_records 集合...');
      await _firestore.collection('exercise_records').add(recordData);
      debugPrint('✅ 成功保存到 exercise_records');

      // 更新每日统计
      debugPrint('开始更新每日统计...');
      await _updateDailyStats(user.uid, date, duration, score);
      debugPrint('✅ 成功更新每日统计');
      
      // 更新运动统计
      debugPrint('开始更新运动统计...');
      await _updateExerciseStats(user.uid, exerciseId, duration, score);
      debugPrint('✅ 成功更新运动统计');

      debugPrint('🎉 所有数据保存完成！');
    } catch (e, stackTrace) {
      debugPrint('❌ 保存失败：$e');
      debugPrint('错误堆栈：$stackTrace');
      rethrow;
    }
  }

  // 更新每日统计
  Future<void> _updateDailyStats(
    String userId,
    DateTime date,
    int duration,
    double score,
  ) async {
    try {
      final dailyStatsRef = _firestore
          .collection('daily_stats')
          .doc(userId)
          .collection('stats')
          .doc(date.toString());

      await _firestore.runTransaction((transaction) async {
        debugPrint('开始每日统计事务...');
        final doc = await transaction.get(dailyStatsRef);
        
        if (doc.exists) {
          debugPrint('更新现有每日统计记录');
          final currentDuration = doc.data()!['totalDuration'] as int;
          final currentCount = doc.data()!['exerciseCount'] as int;
          final currentTotalScore = doc.data()!['totalScore'] as double;
          
          transaction.update(dailyStatsRef, {
            'totalDuration': currentDuration + duration,
            'exerciseCount': currentCount + 1,
            'totalScore': currentTotalScore + score,
            'averageScore': (currentTotalScore + score) / (currentCount + 1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          debugPrint('创建新的每日统计记录');
          transaction.set(dailyStatsRef, {
            'totalDuration': duration,
            'exerciseCount': 1,
            'totalScore': score,
            'averageScore': score,
            'date': date,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        debugPrint('每日统计事务完成');
      });
    } catch (e) {
      debugPrint('❌ 更新每日统计失败：$e');
      rethrow;
    }
  }

  // 更新运动统计
  Future<void> _updateExerciseStats(
    String userId,
    String exerciseId,
    int duration,
    double score,
  ) async {
    try {
      final exerciseStatsRef = _firestore
          .collection('exercise_stats')
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId);

      await _firestore.runTransaction((transaction) async {
        debugPrint('开始运动统计事务...');
        final doc = await transaction.get(exerciseStatsRef);
        
        if (doc.exists) {
          debugPrint('更新现有运动统计记录');
          final currentDuration = doc.data()!['totalDuration'] as int;
          final currentCount = doc.data()!['exerciseCount'] as int;
          final currentTotalScore = doc.data()!['totalScore'] as double;
          
          transaction.update(exerciseStatsRef, {
            'totalDuration': currentDuration + duration,
            'exerciseCount': currentCount + 1,
            'totalScore': currentTotalScore + score,
            'averageScore': (currentTotalScore + score) / (currentCount + 1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          debugPrint('创建新的运动统计记录');
          transaction.set(exerciseStatsRef, {
            'totalDuration': duration,
            'exerciseCount': 1,
            'totalScore': score,
            'averageScore': score,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        debugPrint('运动统计事务完成');
      });
    } catch (e) {
      debugPrint('❌ 更新运动统计失败：$e');
      rethrow;
    }
  }

  // 获取用户的每日统计
  Stream<Map<String, dynamic>> getDailyStats(DateTime date) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('daily_stats')
        .doc(user.uid)
        .collection('stats')
        .doc(date.toString())
        .snapshots()
        .map((doc) => doc.data() ?? {
              'totalDuration': 0,
              'exerciseCount': 0,
              'totalScore': 0.0,
              'averageScore': 0.0,
            });
  }

  // 获取特定运动的统计
  Stream<Map<String, dynamic>> getExerciseStats(String exerciseId) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('exercise_stats')
        .doc(user.uid)
        .collection('exercises')
        .doc(exerciseId)
        .snapshots()
        .map((doc) => doc.data() ?? {
              'totalDuration': 0,
              'exerciseCount': 0,
              'totalScore': 0.0,
              'averageScore': 0.0,
            });
  }
} 