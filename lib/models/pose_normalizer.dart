import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'standard_pose_model.dart';

/// 姿势归一化工具类，用于对齐和比较姿势
class PoseNormalizer {
  /// 计算给定姿势的质心
  /// 返回 [x, y] 质心坐标
  static List<double> calculateCentroid(Map<PoseLandmarkType, dynamic> landmarks) {
    double sumX = 0.0, sumY = 0.0;
    int count = 0;
    
    // 使用上半身主要关键点来计算质心
    final keyPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
    ];
    
    for (final type in keyPoints) {
      final point = landmarks[type];
      if (point != null) {
        sumX += point is PoseLandmark ? point.x : point.x;
        sumY += point is PoseLandmark ? point.y : point.y;
        count++;
      }
    }
    
    return count > 0 ? [sumX / count, sumY / count] : [0.0, 0.0];
  }
  
  /// 计算躯干比例尺度
  /// 使用两肩距离和躯干高度的平均值作为比例尺度
  static double calculateScale(Map<PoseLandmarkType, dynamic> landmarks) {
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    
    double scale = 1.0;
    int measures = 0;
    
    // 计算肩宽
    if (leftShoulder != null && rightShoulder != null) {
      final lsX = leftShoulder is PoseLandmark ? leftShoulder.x : leftShoulder.x;
      final lsY = leftShoulder is PoseLandmark ? leftShoulder.y : leftShoulder.y;
      final rsX = rightShoulder is PoseLandmark ? rightShoulder.x : rightShoulder.x;
      final rsY = rightShoulder is PoseLandmark ? rightShoulder.y : rightShoulder.y;
      
      final shoulderWidth = math.sqrt(math.pow(lsX - rsX, 2) + math.pow(lsY - rsY, 2));
      scale += shoulderWidth;
      measures++;
    }
    
    // 计算躯干高度
    if (leftShoulder != null && leftHip != null) {
      final lsX = leftShoulder is PoseLandmark ? leftShoulder.x : leftShoulder.x;
      final lsY = leftShoulder is PoseLandmark ? leftShoulder.y : leftShoulder.y;
      final lhX = leftHip is PoseLandmark ? leftHip.x : leftHip.x;
      final lhY = leftHip is PoseLandmark ? leftHip.y : leftHip.y;
      
      final torsoHeight = math.sqrt(math.pow(lsX - lhX, 2) + math.pow(lsY - lhY, 2));
      scale += torsoHeight;
      measures++;
    }
    
    if (rightShoulder != null && rightHip != null) {
      final rsX = rightShoulder is PoseLandmark ? rightShoulder.x : rightShoulder.x;
      final rsY = rightShoulder is PoseLandmark ? rightShoulder.y : rightShoulder.y;
      final rhX = rightHip is PoseLandmark ? rightHip.x : rightHip.x;
      final rhY = rightHip is PoseLandmark ? rightHip.y : rightHip.y;
      
      final torsoHeight = math.sqrt(math.pow(rsX - rhX, 2) + math.pow(rsY - rhY, 2));
      scale += torsoHeight;
      measures++;
    }
    
    return measures > 0 ? scale / measures : 1.0;
  }
  
  /// 归一化用户姿势为标准姿势坐标系（0-1之间的值）
  /// - userPose: ML Kit检测到的用户姿势
  /// - imageSize: 相机预览尺寸
  /// 返回归一化后的姿势关键点映射
  static Map<PoseLandmarkType, StandardLandmark> normalizeUserPose(
    Pose userPose, 
    Size imageSize
  ) {
    // 1. 提取用户姿势关键点
    final landmarks = userPose.landmarks;
    
    // 2. 计算质心
    final centroid = calculateCentroid(landmarks);
    
    // 3. 计算尺度
    final scale = calculateScale(landmarks);
    
    // 4. 执行归一化
    final normalizedLandmarks = <PoseLandmarkType, StandardLandmark>{};
    
    landmarks.forEach((type, landmark) {
      // 归一化x坐标 (考虑镜像翻转)
      final normalizedX = (1.0 - landmark.x / imageSize.width - centroid[0] / imageSize.width) / scale;
      
      // 归一化y坐标
      final normalizedY = (landmark.y / imageSize.height - centroid[1] / imageSize.height) / scale;
      
      // 创建标准化关键点
      normalizedLandmarks[type] = StandardLandmark(
        x: 0.5 + normalizedX,  // 中心在0.5
        y: 0.5 + normalizedY,  // 中心在0.5
        z: landmark.z,
      );
    });
    
    return normalizedLandmarks;
  }
  
  /// 转换标准姿势为相对于用户姿势的对齐版本
  /// - standardPose: 标准姿势
  /// - userPose: 用户姿势
  /// - imageSize: 相机预览尺寸
  /// 返回对齐后的标准姿势关键点映射
  static Map<PoseLandmarkType, Offset> alignStandardPoseToUser(
    StandardPose standardPose,
    Pose userPose,
    Size imageSize,
    Size canvasSize,
  ) {
    // 1. 获取用户姿势的参考点（质心和尺度）
    final userCentroid = calculateCentroid(userPose.landmarks);
    final userScale = calculateScale(userPose.landmarks);
    
    // 2. 获取标准姿势的质心和尺度
    final stdCentroid = calculateCentroid(standardPose.landmarks);
    final stdScale = calculateScale(standardPose.landmarks);
    
    // 3. 计算用户质心在画布上的位置
    final userCentroidX = (1.0 - userCentroid[0] / imageSize.width) * canvasSize.width;
    final userCentroidY = (userCentroid[1] / imageSize.height) * canvasSize.height;
    
    // 4. 缩放比例
    final relativeScale = (userScale / imageSize.width) * canvasSize.width;
    
    // 5. 转换标准姿势关键点
    final alignedPoints = <PoseLandmarkType, Offset>{};
    
    standardPose.landmarks.forEach((type, landmark) {
      // 计算相对于标准质心的偏移
      final relativeX = landmark.x - stdCentroid[0];
      final relativeY = landmark.y - stdCentroid[1];
      
      // 应用尺度并定位到用户质心
      final alignedX = userCentroidX + relativeX * relativeScale;
      final alignedY = userCentroidY + relativeY * relativeScale;
      
      alignedPoints[type] = Offset(alignedX, alignedY);
    });
    
    return alignedPoints;
  }
  
  /// 计算两个姿势之间的相似度得分
  static double calculatePoseSimilarity(
    Map<PoseLandmarkType, dynamic> userPose, 
    Map<PoseLandmarkType, dynamic> standardPose,
    Map<PoseLandmarkType, double> weights
  ) {
    double totalScore = 0.0;
    double totalWeight = 0.0;
    int matchedPoints = 0;
    
    // 用于存储每个关键点的得分
    final pointScores = <PoseLandmarkType, double>{};
    
    weights.forEach((type, weight) {
      final userPoint = userPose[type];
      final standardPoint = standardPose[type];
      
      if (userPoint != null && standardPoint != null) {
        // 提取坐标
        final userX = userPoint is PoseLandmark ? userPoint.x : 
                      userPoint is StandardLandmark ? userPoint.x : 
                      userPoint.dx;
        final userY = userPoint is PoseLandmark ? userPoint.y : 
                      userPoint is StandardLandmark ? userPoint.y : 
                      userPoint.dy;
                      
        final stdX = standardPoint is PoseLandmark ? standardPoint.x : 
                     standardPoint is StandardLandmark ? standardPoint.x : 
                     standardPoint.dx;
        final stdY = standardPoint is PoseLandmark ? standardPoint.y : 
                     standardPoint is StandardLandmark ? standardPoint.y : 
                     standardPoint.dy;
        
        // 计算欧氏距离
        final distanceX = userX - stdX;
        final distanceY = userY - stdY;
        final distance = math.sqrt(distanceX * distanceX + distanceY * distanceY);
        
        // 使用指数衰减函数计算分数
        final pointScore = math.exp(-10 * distance) * 100;
        pointScores[type] = pointScore;
        
        totalScore += pointScore * weight;
        totalWeight += weight;
        matchedPoints++;
      }
    });
    
    // 考虑关键点匹配率
    final pointRatio = matchedPoints / weights.length;
    final finalScore = totalWeight > 0 
        ? (totalScore / totalWeight) * pointRatio
        : 0.0;
        
    debugPrint('姿势相似度得分: $finalScore');
    return finalScore;
  }
} 