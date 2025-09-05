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

  String getDisplayName(IssueCategory category) {
    switch (category) {
      case IssueCategory.water:
        return 'Water Issues';
      case IssueCategory.electricity:
        return 'Electrical Issues';
      case IssueCategory.potholes:
        return 'Road/Potholes';
      case IssueCategory.waste:
        return 'Waste Management';
      case IssueCategory.streetlights:
        return 'Street Lighting';
      case IssueCategory.publicSafety:
        return 'Public Safety';
      case IssueCategory.parks:
        return 'Parks & Recreation';
      case IssueCategory.other:
        return 'Other';
    }
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

  IconData getIcon(IssueCategory category) {
    switch (category) {
      case IssueCategory.water:
        return Icons.water_drop;
      case IssueCategory.electricity:
        return Icons.electrical_services;
      case IssueCategory.potholes:
        return Icons.construction;
      case IssueCategory.waste:
        return Icons.delete;
      case IssueCategory.streetlights:
        return Icons.lightbulb;
      case IssueCategory.publicSafety:
        return Icons.security;
      case IssueCategory.parks:
        return Icons.park;
      case IssueCategory.other:
        return Icons.help_outline;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // top
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: Icon(
                          _imagePath == null
                              ? Icons.camera_alt
                              : Icons.camera_alt_outlined,
                        ),
                        label: Text(
                          _imagePath == null ? 'Take Photo' : 'Retake Photo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingLocation)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting location...'),
                        ],
                      )
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          ),
                          Text(
                            'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Location not available',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<IssueCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items:
                          IssueCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(getIcon(category)),
                                  const SizedBox(width: 8),
                                  Text(getDisplayName(category)),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title and description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        hintText: 'Brief title for the issue',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Describe the issue in detail',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // center

            // bottom
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon:
                    _isSubmitting
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
