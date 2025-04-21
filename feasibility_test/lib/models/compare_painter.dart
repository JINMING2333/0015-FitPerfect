import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'standard_pose_model.dart';

class ComparePainter extends CustomPainter {
  final Pose userPose;
  final StandardPose standardPose;
  final Size imageSize;

  ComparePainter({
    required this.userPose,
    required this.standardPose,
    required this.imageSize,
  });

  static final Map<PoseLandmarkType, String> landmarkTypeMap = {
    PoseLandmarkType.nose: 'nose',
    PoseLandmarkType.leftEyeInner: 'left_eye_inner',
    PoseLandmarkType.leftEye: 'left_eye',
    PoseLandmarkType.leftEyeOuter: 'left_eye_outer',
    PoseLandmarkType.rightEyeInner: 'right_eye_inner',
    PoseLandmarkType.rightEye: 'right_eye',
    PoseLandmarkType.rightEyeOuter: 'right_eye_outer',
    PoseLandmarkType.leftEar: 'left_ear',
    PoseLandmarkType.rightEar: 'right_ear',
    PoseLandmarkType.leftMouth: 'left_mouth',
    PoseLandmarkType.rightMouth: 'right_mouth',
    PoseLandmarkType.leftShoulder: 'left_shoulder',
    PoseLandmarkType.rightShoulder: 'right_shoulder',
    PoseLandmarkType.leftElbow: 'left_elbow',
    PoseLandmarkType.rightElbow: 'right_elbow',
    PoseLandmarkType.leftWrist: 'left_wrist',
    PoseLandmarkType.rightWrist: 'right_wrist',
    PoseLandmarkType.leftPinky: 'left_pinky',
    PoseLandmarkType.rightPinky: 'right_pinky',
    PoseLandmarkType.leftIndex: 'left_index',
    PoseLandmarkType.rightIndex: 'right_index',
    PoseLandmarkType.leftThumb: 'left_thumb',
    PoseLandmarkType.rightThumb: 'right_thumb',
    PoseLandmarkType.leftHip: 'left_hip',
    PoseLandmarkType.rightHip: 'right_hip',
    PoseLandmarkType.leftKnee: 'left_knee',
    PoseLandmarkType.rightKnee: 'right_knee',
    PoseLandmarkType.leftAnkle: 'left_ankle',
    PoseLandmarkType.rightAnkle: 'right_ankle',
    PoseLandmarkType.leftHeel: 'left_heel',
    PoseLandmarkType.rightHeel: 'right_heel',
    PoseLandmarkType.leftFootIndex: 'left_foot_index',
    PoseLandmarkType.rightFootIndex: 'right_foot_index',
  };

  // 定义需要连接的关键点对
  static const List<(PoseLandmarkType, PoseLandmarkType)> connections = [
    // 躯干
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
    
    // 左臂
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
    (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
    
    // 右臂
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
    (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
    
    // 左腿
    (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
    (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
    
    // 右腿
    (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
    (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('\n===== ComparePainter 绘制信息 =====');
    debugPrint('画布尺寸: ${size.width}x${size.height}');
    debugPrint('输入图像尺寸: ${imageSize.width}x${imageSize.height}');
    
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    final double scale = math.min(scaleX, scaleY);
    
    final double offsetX = (size.width - imageSize.width * scale) / 2;
    final double offsetY = (size.height - imageSize.height * scale) / 2;

    debugPrint('缩放系数: scaleX=$scaleX, scaleY=$scaleY, scale=$scale');
    debugPrint('偏移量: offsetX=$offsetX, offsetY=$offsetY');

    // 坐标转换函数
    Offset transformUserPoint(PoseLandmark landmark) {
      final double x = size.width - (landmark.x * scale + offsetX);
      final double y = landmark.y * scale + offsetY;
      return Offset(x, y);
    }

    Offset transformStandardPoint(StandardLandmark landmark) {
      final double x = size.width - (landmark.x * scale + offsetX);
      final double y = landmark.y * scale + offsetY;
      return Offset(x, y);
    }

    // 绘制标准姿势（蓝色）
    final standardPaint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // 修改标准姿势的绘制逻辑
    for (final connection in connections) {
      final startType = connection.$1;
      final endType = connection.$2;
      
      // 直接使用 PoseLandmarkType 作为键
      final startPoint = standardPose.landmarks[startType];
      final endPoint = standardPose.landmarks[endType];

      if (startPoint != null && endPoint != null) {
        debugPrint('绘制标准姿势线条: ${startType.name} -> ${endType.name}');
        final startOffset = transformStandardPoint(startPoint);
        final endOffset = transformStandardPoint(endPoint);
        
        canvas.drawLine(startOffset, endOffset, standardPaint);
        
        // 绘制关键点
        canvas.drawCircle(startOffset, 4, Paint()..color = Colors.blue);
        canvas.drawCircle(endOffset, 4, Paint()..color = Colors.blue);
      } else {
        debugPrint('⚠️ 标准姿势缺少关键点: ${startType.name} 或 ${endType.name}');
      }
    }

    // 绘制用户姿势（绿色）
    final userPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // 绘制用户姿势的连接线
    for (final connection in connections) {
      final start = userPose.landmarks[connection.$1];
      final end = userPose.landmarks[connection.$2];

      if (start == null || end == null) continue;

      canvas.drawLine(
        transformUserPoint(start),
        transformUserPoint(end),
        userPaint,
      );
    }

    // 绘制关键点
    final jointPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    // 绘制标准姿势的关键点
    standardPose.landmarks.forEach((_, landmark) {
      canvas.drawCircle(
        transformStandardPoint(landmark),
        4,
        jointPaint,
      );
    });

    // 绘制用户姿势的关键点
    userPose.landmarks.forEach((_, landmark) {
      canvas.drawCircle(
        transformUserPoint(landmark),
        4,
        jointPaint,
      );
    });

    // 添加更多调试信息
    debugPrint('\n===== 标准姿势绘制信息 =====');
    debugPrint('标准姿势关键点总数: ${standardPose.landmarks.length}');
    standardPose.landmarks.forEach((key, value) {
      final transformed = transformStandardPoint(value);
      debugPrint('关键点 $key: 原始(${value.x}, ${value.y}) -> 变换后(${transformed.dx}, ${transformed.dy})');
    });
  }

  @override
  bool shouldRepaint(covariant ComparePainter oldDelegate) {
    return oldDelegate.userPose != userPose || 
           oldDelegate.standardPose != standardPose ||
           oldDelegate.imageSize != imageSize;
  }
}