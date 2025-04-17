import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MaterialApp(home: LivePosePage()));
}

Uint8List concatenatePlanes(CameraImage image) {
  final int totalBytes = image.planes.fold(0, (int sum, plane) => sum + plane.bytes.length);
  final Uint8List allBytes = Uint8List(totalBytes);
  int offset = 0;

  for (final plane in image.planes) {
    allBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
    offset += plane.bytes.length;
  }

  return allBytes;
}


class LivePosePage extends StatefulWidget {
  const LivePosePage({Key? key}) : super(key: key);

  @override
  _LivePosePageState createState() => _LivePosePageState();
}

class _LivePosePageState extends State<LivePosePage> {
  late CameraController _controller;
  final _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    )
  );

  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller.initialize();
    await _controller.startImageStream(_processCameraImage);
    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final bytes = concatenatePlanes(image);

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final camera = cameras.first;
      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final planeData = image.planes.map(
        (plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        setState(() {
          _customPaint = CustomPaint(
            painter: PosePainter(pose, imageSize),
          );
        });
      }
    } catch (e) {
      debugPrint("Pose detection error: $e");
    }

    _isBusy = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Real_time Test")),
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (_customPaint != null) _customPaint!,
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;

  PosePainter(this.pose, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;

    for (final landmark in pose.landmarks.values) {
      final x = landmark.x / imageSize.width * size.width;
      final y = landmark.y / imageSize.height * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) => true;
}
