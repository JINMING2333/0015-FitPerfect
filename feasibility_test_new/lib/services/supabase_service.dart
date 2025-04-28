import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://pxlbvwqznkzrheewxawe.supabase.co',  // 替换为您的 Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4bGJ2d3F6bmt6cmhlZXd4YXdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4NjY1MzEsImV4cCI6MjA2MTQ0MjUzMX0.N0ymc3NPylzbSbs2obL0Z5-fvX9dIV4gu9KJM6t3pbs',  // 替换为您的 Anon Key
    );
    _client = Supabase.instance.client;
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      debugPrint('开始获取运动列表...');
      final response = await _client
          .from('exercises')
          .select();
      
      debugPrint('获取到运动数据: ${response.toString()}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('获取运动列表失败: $e');
      rethrow;
    }
  }

  Future<String> getVideoUrl(String videoPath) async {
    try {
      debugPrint('获取视频URL，路径: $videoPath');
      final String publicUrl = _client
          .storage
          .from('exerciseassets')  // 使用现有的存储桶名称
          .getPublicUrl(videoPath);
      debugPrint('获取到视频URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('获取视频URL失败: $e');
      rethrow;
    }
  }

  Future<String> getJsonUrl(String jsonPath) async {
    try {
      debugPrint('获取JSON URL，路径: $jsonPath');
      final String publicUrl = _client
          .storage
          .from('exerciseassets')  // 使用现有的存储桶名称
          .getPublicUrl(jsonPath);
      debugPrint('获取到JSON URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('获取JSON URL失败: $e');
      rethrow;
    }
  }

  // 新增：直接获取JSON内容的方法
  Future<String> getJsonContent(String jsonPath) async {
    try {
      debugPrint('开始下载JSON文件内容，路径: $jsonPath');
      final List<int> data = await _client
          .storage
          .from('exerciseassets')
          .download(jsonPath);
      
      final String content = String.fromCharCodes(data);
      debugPrint('成功获取JSON内容，长度: ${content.length}');
      return content;
    } catch (e) {
      debugPrint('获取JSON内容失败: $e');
      rethrow;
    }
  }
} 