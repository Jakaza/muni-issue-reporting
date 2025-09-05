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

  /// Submit the report
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      _showError('Please take a photo of the issue');
      return;
    }
    if (_currentPosition == null) {
      _showError('Location is required. Please enable GPS and try again.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = IssueReport(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        imagePath: _imagePath!,
        createdAt: DateTime.now(),
      );

      final success = await ReportService.saveReport(report);

      if (success) {
        _showSuccess('Report submitted successfully!');
        Navigator.pop(context);
      } else {
        _showError('Failed to submit report. Please try again.');
      }
    } catch (e) {
      _showError('Error submitting report: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: Text("Jakaza"),
    );
  }
}
