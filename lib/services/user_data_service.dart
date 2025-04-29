import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 获取当前用户ID
  String? get userId => _auth.currentUser?.uid;
  
  // 检查用户是否登录
  bool get isLoggedIn => _auth.currentUser != null;

  // 获取用户训练历史
  Stream<QuerySnapshot> getTrainingHistory() {
    if (!isLoggedIn) {
      // 如果未登录，返回一个空流
      // 创建一个空的 QuerySnapshot 并返回
      return Stream<QuerySnapshot>.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('training_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 保存训练记录
  Future<void> saveTrainingRecord({
    required String exercise,
    required int duration,
    required double score,
    required String imageUrl, // 可选：训练截图URL
    Map<String, dynamic>? additionalData, // 额外数据
  }) async {
    if (!isLoggedIn) {
      throw Exception('未登录');
    }

    try {
      // 创建训练记录文档
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('training_history')
          .add({
        'exercise': exercise,
        'duration': duration,
        'score': score,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      
      // 更新用户总统计数据
      await _firestore.collection('users').doc(userId).update({
        'totalTrainings': FieldValue.increment(1),
        'totalDuration': FieldValue.increment(duration),
        'lastTrainingDate': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('保存训练记录错误: $e');
      rethrow;
    }
  }

  // 获取用户信息
  Future<DocumentSnapshot?> getUserProfile() async {
    if (!isLoggedIn) return null;
    
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      debugPrint('获取用户信息错误: $e');
      return null;
    }
  }

  // 更新用户信息
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isLoggedIn) return false;
    
    try {
      Map<String, dynamic> updateData = {};
      
      if (displayName != null) {
        updateData['username'] = displayName;
        // 同时更新Firebase Auth的用户名
        await _auth.currentUser!.updateDisplayName(displayName);
      }
      
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
        // 同时更新Firebase Auth的头像
        await _auth.currentUser!.updatePhotoURL(photoUrl);
      }
      
      if (additionalData != null) {
        updateData.addAll(additionalData);
      }
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      debugPrint('更新用户信息错误: $e');
      return false;
    }
  }

  // 删除训练记录
  Future<bool> deleteTrainingRecord(String recordId) async {
    if (!isLoggedIn) return false;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('training_history')
          .doc(recordId)
          .delete();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('删除训练记录错误: $e');
      return false;
    }
  }

  // 获取用户统计数据
  Future<Map<String, dynamic>> getUserStats() async {
    if (!isLoggedIn) {
      return {
        'totalTrainings': 0,
        'totalDuration': 0,
        'averageScore': 0.0,
      };
    }
    
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        return {
          'totalTrainings': 0,
          'totalDuration': 0,
          'averageScore': 0.0,
        };
      }
      
      final data = doc.data()!;
      
      // 计算平均分数
      double averageScore = 0;
      if (data.containsKey('totalTrainings') && data['totalTrainings'] > 0) {
        final historyQuery = await _firestore
            .collection('users')
            .doc(userId)
            .collection('training_history')
            .get();
        
        double totalScore = 0;
        for (var doc in historyQuery.docs) {
          totalScore += (doc.data()['score'] as num).toDouble();
        }
        
        averageScore = totalScore / historyQuery.docs.length;
      }
      
      return {
        'totalTrainings': data['totalTrainings'] ?? 0,
        'totalDuration': data['totalDuration'] ?? 0,
        'averageScore': averageScore,
        'lastTrainingDate': data['lastTrainingDate'],
      };
    } catch (e) {
      debugPrint('获取用户统计数据错误: $e');
      return {
        'totalTrainings': 0,
        'totalDuration': 0,
        'averageScore': 0.0,
        'error': e.toString(),
      };
    }
  }
} 