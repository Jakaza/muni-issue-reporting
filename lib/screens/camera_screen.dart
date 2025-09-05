import 'package:camera_platform_interface/src/types/camera_description.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required CameraDescription camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
