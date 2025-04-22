import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'community_service.dart';

// 状态服务，用于管理对话框的状态
class PostDialogService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  // getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  // 重置状态
  void reset() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }

  // 发布新帖子
  Future<bool> createPost(CommunityService communityService, String content, {String? title}) async {
    try {
      _isLoading = true;
      _error = null;
      _isSuccess = false;
      notifyListeners();

      // 调用社区服务发布帖子
      final success = await communityService.createPost(
        content: content,
        title: title,
        // 移除图片功能
        imageUrl: null,
      );

      _isLoading = false;
      _isSuccess = success;
      
      if (!success) {
        _error = "Failed to create post";
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _isSuccess = false;
      notifyListeners();
      return false;
    }
  }

  // 添加评论
  Future<bool> addComment(CommunityService communityService, String postId, String content) async {
    try {
      _isLoading = true;
      _error = null;
      _isSuccess = false;
      notifyListeners();

      // 调用社区服务添加评论
      final success = await communityService.addComment(
        postId: postId,
        content: content,
      );

      _isLoading = false;
      _isSuccess = success;
      
      if (!success) {
        _error = "Failed to add comment";
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _isSuccess = false;
      notifyListeners();
      return false;
    }
  }
} 