import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muni/screens/camera_screen.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/issue_report.dart';
import '../services/report_service.dart';
import '../services/location_service.dart';
// import 'camera_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _imagePath;
  IssueCategory _selectedCategory = IssueCategory.other;
  Position? _currentPosition;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Take a photo using camera
  Future<void> _takePhoto() async {
    if (cameras.isEmpty) {
      _showError('No cameras available');
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: cameras.first),
      ),
    );

    if (result != null) {
      setState(() => _imagePath = result);
    }
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        setState(() => _currentPosition = position);
      } else {
        _showError('Unable to get your location. Please enable GPS.');
      }
    } catch (e) {
      _showError('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("Report Screen will be implemented"));
  }
}
