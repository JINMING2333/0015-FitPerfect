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
  
  /// 创建一个空的标准姿势
  factory StandardPose.empty() {
    return StandardPose(
      idx: 0,
      timestamp: 0.0,
      imgPath: '',
      landmarks: {},
    );
  }

  factory StandardPose.fromJson(Map<String, dynamic> json) {
    final landmarks = <PoseLandmarkType, StandardLandmark>{};
    
    // 创建键名映射
    final nameToType = Map<String, PoseLandmarkType>.fromEntries(
      PoseLandmarkType.values.map((type) => 
        MapEntry(type.name.replaceAllMapped(
          RegExp(r'[A-Z]'), 
          (match) => '_${match.group(0)!.toLowerCase()}'
        ).toLowerCase(), type)
      )
    );

    (json['landmarks'] as Map<String, dynamic>).forEach((key, value) {
      final type = nameToType[key];
      if (type != null) {
        final coords = (value as List).cast<double>();
        landmarks[type] = StandardLandmark(
          x: coords[0],
          y: coords[1],
          z: coords[2],
        );
      }
    });

    return StandardPose(
      idx: json['idx'] as int,
      timestamp: json['timestamp'] as double,
      landmarks: landmarks,
      imgPath: json['img_path'] as String,
    );
  }

  /// 从 assets 载入标准动作序列
  static Future<List<StandardPose>> loadFromAssets(String path) async {
    try {
      debugPrint('\n===== 加载标准姿势数据 =====');
      final jsonString = await rootBundle.loadString(path);
      debugPrint('JSON数据长度: ${jsonString.length}');
      
      // 使用 compute 在后台线程解析大型 JSON
      final List<dynamic> jsonList = await compute(_parseJsonString, jsonString);
      debugPrint('解析到姿势帧数: ${jsonList.length}');
      
      // 使用 compute 在后台线程处理大量数据
      final poses = await compute(_parseStandardPoses, jsonList);
      
      debugPrint('成功加载姿势数: ${poses.length}');
      return poses;
    } catch (e, stack) {
      debugPrint('❌ 加载标准姿势失败: $e');
      debugPrint('堆栈: $stack');
      return [];
    }
  }
  
  /// 在后台线程解析 JSON 字符串
  static List<dynamic> _parseJsonString(String jsonString) {
    return json.decode(jsonString);
  }
  
  /// 在后台线程解析标准姿势列表
  static List<StandardPose> _parseStandardPoses(List<dynamic> jsonList) {
    return jsonList.map((poseJson) {
      return StandardPose(
        idx: poseJson['idx'] as int? ?? 0,
        timestamp: (poseJson['timestamp'] as num?)?.toDouble() ?? 0.0,
        imgPath: poseJson['img_path'] as String? ?? '',
        landmarks: _parseLandmarks(poseJson['landmarks'] as Map<String, dynamic>? ?? {}),
      );
    }).toList();
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

  static List<StandardPose> parseStandardPoses(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => StandardPose.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// 从JSON列表创建标准姿势列表
  static List<StandardPose> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StandardPose.fromJson(json as Map<String, dynamic>)).toList();
  }
}
