import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'standard_pose_model.dart';
import 'pose_normalizer.dart';

class ComparePainter extends CustomPainter {
  final Pose userPose;
  final StandardPose standardPose;
  final Size imageSize;
  final bool showStandardPose;

  ComparePainter({
    required this.userPose,
    required this.standardPose,
    required this.imageSize,
    this.showStandardPose = true,
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
    
    // 使用姿势归一化工具对齐标准姿势
    final alignedStandardPose = PoseNormalizer.alignStandardPoseToUser(
      standardPose,
      userPose,
      imageSize,
      size,
    );

    // 坐标转换函数 - 用户姿势需要镜像
    Offset transformUserPoint(PoseLandmark landmark) {
      // 翻转X轴方向，使其与前置摄像头匹配
      return Offset(
        size.width - (landmark.x / imageSize.width * size.width),
        landmark.y / imageSize.height * size.height
      );
    }

    // 记录要绘制的点和线，确保标准姿势先绘制，用户姿势后绘制
    final standardLines = <(Offset, Offset)>[];
    final standardPoints = <Offset>[];
    final userLines = <(Offset, Offset)>[];
    final userPoints = <Offset>[];

    // 收集标准姿势的线条和关键点
    for (final connection in connections) {
      final startType = connection.$1;
      final endType = connection.$2;
      
      final startPoint = alignedStandardPose[startType];
      final endPoint = alignedStandardPose[endType];

      if (startPoint != null && endPoint != null) {
        debugPrint('绘制标准姿势线条: ${startType.name} -> ${endType.name}');
        
        standardLines.add((startPoint, endPoint));
        standardPoints.add(startPoint);
        standardPoints.add(endPoint);
      } else {
        debugPrint('⚠️ 标准姿势缺少关键点: ${startType.name} 或 ${endType.name}');
      }
    }

    // 收集用户姿势的线条和关键点
    for (final connection in connections) {
      final start = userPose.landmarks[connection.$1];
      final end = userPose.landmarks[connection.$2];

      if (start == null || end == null) continue;

      final startOffset = transformUserPoint(start);
      final endOffset = transformUserPoint(end);
      
      userLines.add((startOffset, endOffset));
      userPoints.add(startOffset);
      userPoints.add(endOffset);
    }

    // 先绘制标准姿势 - 蓝色
    if (showStandardPose) {
      final standardPaint = Paint()
        ..color = Colors.blue.withOpacity(0.9)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke;

      final standardJointPaint = Paint()
        ..color = Colors.blue.withOpacity(1.0)
        ..strokeWidth = 8
        ..style = PaintingStyle.fill;

      // 绘制标准姿势的线条
      for (final line in standardLines) {
        canvas.drawLine(line.$1, line.$2, standardPaint);
      }

      // 绘制标准姿势的关键点
      for (final point in standardPoints) {
        canvas.drawCircle(point, 4, standardJointPaint);
      }
    }

    // 然后绘制用户姿势 - 绿色
    final userPaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final userJointPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    // 绘制用户姿势的线条
    for (final line in userLines) {
      canvas.drawLine(line.$1, line.$2, userPaint);
    }

    // 绘制用户姿势的关键点
    for (final point in userPoints) {
      canvas.drawCircle(point, 3, userJointPaint);
    }

    // 添加更多调试信息
    debugPrint('\n===== 姿势对齐信息 =====');
    debugPrint('标准姿势关键点总数: ${standardPose.landmarks.length}');
    debugPrint('对齐后的标准姿势关键点总数: ${alignedStandardPose.length}');
  }

  @override
  bool shouldRepaint(covariant ComparePainter oldDelegate) {
    return oldDelegate.userPose != userPose || 
           oldDelegate.standardPose != standardPose ||
           oldDelegate.imageSize != imageSize ||
           oldDelegate.showStandardPose != showStandardPose;
  }
}