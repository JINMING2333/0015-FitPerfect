// lib/screens/pose_compare_page.dart

import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:video_player/video_player.dart';
import '../models/standard_pose_model.dart';
import '../models/compare_painter.dart';

late List<CameraDescription> cameras;

class PoseComparePage extends StatefulWidget {
  const PoseComparePage({Key? key}) : super(key: key);

  @override
  State<PoseComparePage> createState() => _PoseComparePageState();
}

class _PoseComparePageState extends State<PoseComparePage> {
  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  VideoPlayerController? _videoController;
  bool _initialized = false;

  final _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  List<StandardPose> _standardPoses = [];
  Pose? _userPose;
  bool _isBusy = false;
  final double _threshold = 0.1;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadResources);
  }

  Future<void> _loadResources() async {
    try {
      // 1. Load standard poses
      _standardPoses =
          await StandardPose.loadFromAssets('assets/standard_cycle.json');

      // 2. Init camera
      cameras = await availableCameras();
      _cameraDescription = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
      );
      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processCameraImage);

      // 3. Init video
      _videoController = VideoPlayerController.asset('assets/demo.mp4');
      await _videoController!.initialize();
      _videoController!
        ..setLooping(true)
        ..play();
    } catch (e) {
      debugPrint('🔴 资源加载失败: $e');
    } finally {
      if (mounted) setState(() => _initialized = true);
    }
  }

  /// 拼接所有 plane 的 bytes
  Uint8List _concatenatePlanes(CameraImage image) {
    final builder = BytesBuilder();
    for (final plane in image.planes) {
      builder.add(plane.bytes);
    }
    return builder.toBytes();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      debugPrint('\n===== 开始处理图像帧 =====');
      debugPrint('图像基本信息:');
      debugPrint('- 分辨率: ${image.width}x${image.height}');
      debugPrint('- 格式代码: ${image.format.raw}');
      debugPrint('- 平面数量: ${image.planes.length}');

      // 1. 拼平面
      final bytes = image.planes.first.bytes;
      debugPrint('图像数据:');
      debugPrint('- Y平面大小: ${bytes.length}');
      debugPrint('- 前10个像素值: ${bytes.take(10).toList()}');

      // 2. 构造 planeData
      final planeData = <InputImagePlaneMetadata>[
        InputImagePlaneMetadata(
          bytesPerRow: image.planes.first.bytesPerRow,
          height: image.height,
          width: image.width,
        ),
      ];

      // 3. 构造 InputImage
      final rotation = InputImageRotationValue.fromRawValue(
            _cameraDescription!.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw)!;

      debugPrint('相机配置:');
      debugPrint('- 传感器方向: ${_cameraDescription!.sensorOrientation}°');
      debugPrint('- 使用旋转值: $rotation');
      debugPrint('- 镜头方向: ${_cameraDescription!.lensDirection}');
      debugPrint('- 图像格式: $format');

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: InputImageData(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          imageRotation: rotation,
          inputImageFormat: format,
          planeData: planeData,
        ),
      );

      debugPrint('\n开始姿势检测...');
      final startTime = DateTime.now();
      final poses = await _poseDetector.processImage(inputImage);
      final endTime = DateTime.now();
      final processingTime = endTime.difference(startTime).inMilliseconds;
      
      debugPrint('检测完成:');
      debugPrint('- 处理时间: ${processingTime}ms');
      debugPrint('- 检测到姿势: ${poses.length}个');

      if (poses.isNotEmpty) {
        final pose = poses.first;
        final landmarks = pose.landmarks;
        debugPrint('\n姿势详情:');
        debugPrint('- 关键点数量: ${landmarks.length}');
        
        // 检查关键点
        final hasNose = landmarks.containsKey(PoseLandmarkType.nose);
        final hasLeftShoulder = landmarks.containsKey(PoseLandmarkType.leftShoulder);
        final hasRightShoulder = landmarks.containsKey(PoseLandmarkType.rightShoulder);
        
        debugPrint('主要关键点:');
        debugPrint('- 鼻子: ${hasNose ? "已检测" : "未检测"}');
        debugPrint('- 左肩: ${hasLeftShoulder ? "已检测" : "未检测"}');
        debugPrint('- 右肩: ${hasRightShoulder ? "已检测" : "未检测"}');

        if (landmarks.isNotEmpty) {
          debugPrint('\n部分关键点坐标:');
          landmarks.entries.take(3).forEach((entry) {
            final point = entry.value;
            debugPrint('- ${entry.key.name}: '
                'x=${point.x.toStringAsFixed(1)}, '
                'y=${point.y.toStringAsFixed(1)}, '
                'z=${point.z.toStringAsFixed(1)}');
          });
        }

        setState(() => _userPose = pose);
      } else {
        debugPrint('⚠️ 未检测到任何姿势');
      }

      debugPrint('===== 图像处理完成 =====\n');
    } catch (e, st) {
      debugPrint('❌ 处理出错: $e\n$st');
    } finally {
      _isBusy = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _videoController == null ||
        !_videoController!.value.isInitialized ||
        _standardPoses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 选取标准帧
    final posMs = _videoController!.value.position.inMilliseconds;
    final totalMs = _videoController!.value.duration.inMilliseconds;
    final idx = (_standardPoses.length * posMs / totalMs)
        .clamp(0, _standardPoses.length - 1)
        .toInt();
    final standard = _standardPoses[idx];

    // 获取预览尺寸，如果无法获取则使用默认值
    final previewSize = _cameraController?.value.previewSize;
    final imageSize = Size(
      previewSize?.height ?? 640.0,  // 旋转90度后宽度是原高度
      previewSize?.width ?? 480.0,   // 旋转90度后高度是原宽度
    );

    debugPrint('\n===== 标准姿势数据 =====');
    debugPrint('标准姿势索引: $idx');
    debugPrint('标准姿势关键点数: ${standard.landmarks.length}');
    if (standard.landmarks.isNotEmpty) {
      debugPrint('部分标准关键点坐标:');
      standard.landmarks.entries.take(3).forEach((entry) {
        debugPrint('- ${entry.key}: (${entry.value.x}, ${entry.value.y})');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pose 比对')),
      body: Column(
        children: [
          Expanded(child: VideoPlayer(_videoController!)),
          Expanded(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    debugPrint('\n===== 相机预览布局信息 =====');
                    debugPrint('Stack 约束: ${constraints.toString()}');
                    debugPrint('相机预览尺寸: ${_cameraController!.value.previewSize}');
                    debugPrint('相机预览比例: ${_cameraController!.value.aspectRatio}');
                    
                    // 计算适合的尺寸
                    final size = _cameraController!.value.previewSize!;
                    final deviceRatio = constraints.maxWidth / constraints.maxHeight;
                    final previewRatio = size.height / size.width; // 注意这里交换了宽高
                    
                    // 根据宽高比计算最终尺寸
                    final scale = deviceRatio < previewRatio 
                        ? constraints.maxWidth / size.height
                        : constraints.maxHeight / size.width;
                    
                    final previewW = size.height * scale;
                    final previewH = size.width * scale;
                    
                    debugPrint('计算后的预览尺寸: ${previewW}x${previewH}');
                    
                    return Center(
                      child: SizedBox(
                        width: previewW,
                        height: previewH,
                        child: ClipRect(
                          child: Transform.scale(
                            scale: 1.0,
                            child: Center(
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_userPose != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      debugPrint('\n===== CustomPaint 布局信息 =====');
                      debugPrint('CustomPaint 约束: ${constraints.toString()}');
                      
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ComparePainter(
                          userPose: _userPose!,
                          imageSize: Size(
                            _cameraController!.value.previewSize?.height ?? 640.0,
                            _cameraController!.value.previewSize?.width ?? 480.0,
                          ),
                        ),
                      );
                    },
                  ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '检测状态: ${_userPose != null ? "已检测" : "未检测"}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (_userPose != null) Text(
                          '关键点数: ${_userPose!.landmarks.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}