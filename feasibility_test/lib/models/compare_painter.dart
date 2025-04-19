import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ComparePainter extends CustomPainter {
  final Pose userPose;
  final Size imageSize;

  ComparePainter({
    required this.userPose,
    required this.imageSize,
  });

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
    
    // 计算缩放因子和偏移量
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    final double scale = math.min(scaleX, scaleY);
    
    // 计算居中偏移
    final double offsetX = (size.width - imageSize.width * scale) / 2;
    final double offsetY = (size.height - imageSize.height * scale) / 2;

    debugPrint('缩放系数: scaleX=$scaleX, scaleY=$scaleY, scale=$scale');
    debugPrint('偏移量: offsetX=$offsetX, offsetY=$offsetY');

    // 坐标转换函数
    Offset transformPoint(PoseLandmark landmark) {
      // 镜像 X 坐标
      final double x = size.width - (landmark.x * scale + offsetX);
      final double y = landmark.y * scale + offsetY;
      return Offset(x, y);
    }

    // 设置画笔
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // 绘制骨骼连接线
    for (final connection in connections) {
      final start = userPose.landmarks[connection.$1];
      final end = userPose.landmarks[connection.$2];

      if (start == null || end == null) continue;

      canvas.drawLine(
        transformPoint(start),
        transformPoint(end),
        paint,
      );
    }

    // 绘制关键点
    final jointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.fill;

    userPose.landmarks.forEach((_, landmark) {
      canvas.drawCircle(
        transformPoint(landmark),
        4,
        jointPaint,
      );
    });

    // 添加调试信息
    debugPrint('\n===== 绘制信息 =====');
    debugPrint('画布尺寸: ${size.width}x${size.height}');
    debugPrint('图像尺寸: ${imageSize.width}x${imageSize.height}');
    debugPrint('缩放系数: $scale');
    debugPrint('偏移量: ($offsetX, $offsetY)');
    debugPrint('关键点数量: ${userPose.landmarks.length}');
  }

  @override
  bool shouldRepaint(covariant ComparePainter oldDelegate) {
    return oldDelegate.userPose != userPose || 
           oldDelegate.imageSize != imageSize;
  }
}