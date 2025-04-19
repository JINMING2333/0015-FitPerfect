import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

/// 单个关键点模型
class StandardLandmark {
  final double x;
  final double y;
  final double z;

  StandardLandmark({
    required this.x,
    required this.y,
    required this.z,
  });

  factory StandardLandmark.fromJson(List<dynamic> json) {
    return StandardLandmark(
      x: (json[0] as num).toDouble(),
      y: (json[1] as num).toDouble(),
      z: (json[2] as num).toDouble(),
    );
  }

  factory StandardLandmark.fromMLKit(PoseLandmark mlkitLandmark) {
    return StandardLandmark(
      x: mlkitLandmark.x,
      y: mlkitLandmark.y,
      z: mlkitLandmark.z,
    );
  }
}

/// 一个标准动作帧模型
class StandardPose {
  /// 帧索引
  final int idx;
  
  /// 视频时间戳（秒）
  final double timestamp;

  /// 对应的图片路径
  final String imgPath;

  /// 关键点映射表，键为身体部位名称
  final Map<PoseLandmarkType, StandardLandmark> landmarks;

  StandardPose({
    required this.idx,
    required this.timestamp,
    required this.imgPath,
    required this.landmarks,
  });

  factory StandardPose.fromJson(Map<String, dynamic> json) {
    final rawLm = json['landmarks'] as Map<String, dynamic>;
    final lmMap = <PoseLandmarkType, StandardLandmark>{};
    
    // 将JSON中的关键点名称转换为PoseLandmarkType
    for (var entry in rawLm.entries) {
      final landmarkType = _stringToPoseLandmarkType(entry.key);
      if (landmarkType != null) {
        lmMap[landmarkType] = StandardLandmark.fromJson(entry.value as List<dynamic>);
      }
    }

    return StandardPose(
      idx: json['idx'] as int,
      timestamp: (json['timestamp'] as num).toDouble(),
      imgPath: json['img_path'] as String,
      landmarks: lmMap,
    );
  }

  /// 从 assets 载入标准动作序列
  static Future<List<StandardPose>> loadFromAssets(String path) async {
    try {
      debugPrint('\n===== 加载标准姿势数据 =====');
      final jsonString = await rootBundle.loadString(path);
      debugPrint('JSON数据长度: ${jsonString.length}');
      final List<dynamic> jsonList = json.decode(jsonString);
      debugPrint('解析到姿势帧数: ${jsonList.length}');
      
      final poses = jsonList.map((poseJson) {
        return StandardPose(
          idx: poseJson['idx'] as int? ?? 0,
          timestamp: (poseJson['timestamp'] as num?)?.toDouble() ?? 0.0,
          imgPath: poseJson['img_path'] as String? ?? '',
          landmarks: _parseLandmarks(poseJson['landmarks'] as Map<String, dynamic>? ?? {}),
        );
      }).toList();
      
      debugPrint('成功加载姿势数: ${poses.length}');
      return poses;
    } catch (e, stack) {
      debugPrint('❌ 加载标准姿势失败: $e');
      debugPrint('堆栈: $stack');
      return [];
    }
  }

  /// 将字符串转换为PoseLandmarkType
  static PoseLandmarkType? _stringToPoseLandmarkType(String name) {
    final map = {
      'nose': PoseLandmarkType.nose,
      'left_eye_inner': PoseLandmarkType.leftEyeInner,
      'left_eye': PoseLandmarkType.leftEye,
      'left_eye_outer': PoseLandmarkType.leftEyeOuter,
      'right_eye_inner': PoseLandmarkType.rightEyeInner,
      'right_eye': PoseLandmarkType.rightEye,
      'right_eye_outer': PoseLandmarkType.rightEyeOuter,
      'left_ear': PoseLandmarkType.leftEar,
      'right_ear': PoseLandmarkType.rightEar,
      'left_shoulder': PoseLandmarkType.leftShoulder,
      'right_shoulder': PoseLandmarkType.rightShoulder,
      'left_elbow': PoseLandmarkType.leftElbow,
      'right_elbow': PoseLandmarkType.rightElbow,
      'left_wrist': PoseLandmarkType.leftWrist,
      'right_wrist': PoseLandmarkType.rightWrist,
      'left_hip': PoseLandmarkType.leftHip,
      'right_hip': PoseLandmarkType.rightHip,
      'left_knee': PoseLandmarkType.leftKnee,
      'right_knee': PoseLandmarkType.rightKnee,
      'left_ankle': PoseLandmarkType.leftAnkle,
      'right_ankle': PoseLandmarkType.rightAnkle,
    };
    
    return map[name.toLowerCase()];
  }

  /// 添加辅助方法来解析关键点数据
  static Map<PoseLandmarkType, StandardLandmark> _parseLandmarks(Map<String, dynamic> json) {
    final landmarks = <PoseLandmarkType, StandardLandmark>{};
    
    json.forEach((key, value) {
      final landmarkType = _stringToPoseLandmarkType(key);
      if (landmarkType != null && value is List) {
        try {
          landmarks[landmarkType] = StandardLandmark.fromJson(value);
        } catch (e) {
          debugPrint('解析关键点失败 $key: $e');
        }
      }
    });
    
    return landmarks;
  }
}
