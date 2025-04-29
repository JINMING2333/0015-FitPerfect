import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:io';

class PoseImageTestPage extends StatefulWidget {
  const PoseImageTestPage({super.key});

  @override
  State<PoseImageTestPage> createState() => _PoseImageTestPageState();
}

class _PoseImageTestPageState extends State<PoseImageTestPage> {
  String _result = 'select a picture';
  XFile? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickAndDetectPose() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      setState(() {
        _result = '❌ select fail';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '🧠 analyzing now...';
      _selectedImage = image;
    });

    final inputImage = InputImage.fromFilePath(image.path);
    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );

    final poses = await poseDetector.processImage(inputImage);
    await poseDetector.close();

    if (poses.isEmpty) {
      setState(() {
        _result = '⚠️ detected 0';
        _isLoading = false;
      });
      return;
    }

    final pose = poses.first;
    final landmarks = pose.landmarks;

    setState(() {
      _result = '✅ ${landmarks.length} key\n';
      for (final entry in landmarks.entries) {
        _result += '${entry.key.name}: (${entry.value.x.toStringAsFixed(2)}, ${entry.value.y.toStringAsFixed(2)})\n';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('p_test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndDetectPose,
              child: const Text('select_p_t'),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 250,
              ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
