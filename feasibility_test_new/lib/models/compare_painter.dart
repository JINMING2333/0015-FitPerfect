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
    required this.showStandardPose,
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
    // 只绘制用户姿势的骨骼线条（绿色）
    _drawPose(
      canvas,
      userPose.landmarks,
      size,
      const Color(0xFF00FF00),  // 使用绿色
      strokeWidth: 4,
      mirrorX: true,  // 镜像X轴，因为前置摄像头
    );
  }

  void _drawPose(
    Canvas canvas,
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    Size size,
    Color color, {
    double strokeWidth = 2,
    bool mirrorX = false,  // 添加镜像参数
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    void drawLine(
      PoseLandmarkType type1,
      PoseLandmarkType type2,
      Canvas canvas,
      Size size,
      Paint paint,
    ) {
      if (!landmarks.containsKey(type1) || !landmarks.containsKey(type2)) {
        return;
      }

      final PoseLandmark joint1 = landmarks[type1]!;
      final PoseLandmark joint2 = landmarks[type2]!;

      // 计算坐标，如果需要则镜像
      double x1 = joint1.x * size.width / imageSize.width;
      double x2 = joint2.x * size.width / imageSize.width;
      
      if (mirrorX) {
        x1 = size.width - x1;
        x2 = size.width - x2;
      }

      canvas.drawLine(
        Offset(
          x1,
          joint1.y * size.height / imageSize.height,
        ),
        Offset(
          x2,
          joint2.y * size.height / imageSize.height,
        ),
        paint,
      );
    }

    // Draw arms
    drawLine(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
      canvas,
      size,
      paint,
    );

    // Draw body
    drawLine(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      canvas,
      size,
      paint,
    );

    // Draw legs
    drawLine(
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      canvas,
      size,
      paint,
    );
    drawLine(
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      canvas,
      size,
      paint,
    );
  }

  @override
  bool shouldRepaint(ComparePainter oldDelegate) {
    return oldDelegate.userPose != userPose ||
        oldDelegate.standardPose != standardPose;
  }
}