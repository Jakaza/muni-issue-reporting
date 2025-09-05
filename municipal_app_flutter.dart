// pubspec.yaml dependencies needed:
/*
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5
  geolocator: ^9.0.2
  path_provider: ^2.1.1
  path: ^1.8.3
  permission_handler: ^11.0.1
  shared_preferences: ^2.2.2
  uuid: ^4.1.0
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
*/

// main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'services/report_service.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
  }
  
  runApp(MunicipalReporterApp());
}

class MunicipalReporterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Municipal Issue Reporter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// models/issue_report.dart
import 'dart:convert';

enum IssueCategory {
  water,
  electricity,
  potholes,
  waste,
  streetlights,
  publicSafety,
  parks,
  other
}

enum ReportStatus {
  submitted,
  inProgress,
  resolved,
  rejected
}

class IssueReport {
  final String id;
  final String title;
  final String description;
  final IssueCategory category;
  final double latitude;
  final double longitude;
  final String imagePath;
  final DateTime createdAt;
  ReportStatus status;

  IssueReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.createdAt,
    this.status = ReportStatus.submitted,
  });

  // Convert to JSON for server communication
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  // Create from JSON
  factory IssueReport.fromJson(Map<String, dynamic> json) {
    return IssueReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: IssueCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category']
      ),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status']
      ),
    );
  }

  // Get category display name
  String get categoryDisplayName {
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

  // Get category icon
  IconData get categoryIcon {
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

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case ReportStatus.submitted:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
}

// services/report_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/issue_report.dart';

/// Service class to manage issue reports
/// Handles local storage, file management, and future server communication
class ReportService {
  static const String _reportsKey = 'saved_reports';
  
  /// Save a new report locally
  static Future<bool> saveReport(IssueReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await getAllReports();
      reports.add(report);
      
      final reportsJson = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(reportsJson));
      
      // Print details for server submission (placeholder)
      _printReportDetails(report);
      
      return true;
    } catch (e) {
      print('Error saving report: $e');
      return false;
    }
  }
  
  /// Get all saved reports
  static Future<List<IssueReport>> getAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsString = prefs.getString(_reportsKey);
      
      if (reportsString == null) return [];
      
      final reportsJson = jsonDecode(reportsString) as List;
      return reportsJson.map((json) => IssueReport.fromJson(json)).toList();
    } catch (e) {
      print('Error loading reports: $e');
      return [];
    }
  }
  
  /// Update report status (for when server communication is implemented)
  static Future<bool> updateReportStatus(String reportId, ReportStatus newStatus) async {
    try {
      final reports = await getAllReports();
      final reportIndex = reports.indexWhere((r) => r.id == reportId);
      
      if (reportIndex != -1) {
        reports[reportIndex].status = newStatus;
        
        final prefs = await SharedPreferences.getInstance();
        final reportsJson = reports.map((r) => r.toJson()).toList();
        await prefs.setString(_reportsKey, jsonEncode(reportsJson));
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating report status: $e');
      return false;
    }
  }
  
  /// Create the reports directory if it doesn't exist
  static Future<Directory> getReportsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDir.path}/municipal_reports');
    
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    
    return reportsDir;
  }
  
  /// Print report details for server submission (placeholder)
  static void _printReportDetails(IssueReport report) {
    print('\n========== REPORT TO BE SENT TO SERVER ==========');
    print('Report ID: ${report.id}');
    print('Title: ${report.title}');
    print('Description: ${report.description}');
    print('Category: ${report.categoryDisplayName}');
    print('Location: ${report.latitude}, ${report.longitude}');
    print('Image Path: ${report.imagePath}');
    print('Created At: ${report.createdAt}');
    print('Status: ${report.statusDisplayName}');
    print('JSON Payload:');
    print(jsonEncode(report.toJson()));
    print('================================================\n');
  }
  
  /// Future method for server communication
  static Future<bool> submitToServer(IssueReport report) async {
    // TODO: Implement actual REST API communication
    // This is a placeholder for future server integration
    
    try {
      // Example of what the server call might look like:
      /*
      final response = await http.post(
        Uri.parse('https://your-municipality-api.com/reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      );
      
      if (response.statusCode == 201) {
        // Update local status
        await updateReportStatus(report.id, ReportStatus.submitted);
        return true;
      }
      */
      
      // For now, just simulate success
      _printReportDetails(report);
      return true;
      
    } catch (e) {
      print('Error submitting to server: $e');
      return false;
    }
  }
}

// services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle GPS location functionality
class LocationService {
  /// Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }
  
  /// Get current GPS position
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}

// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'report_issue_screen.dart';
import 'my_reports_screen.dart';

/// Main home screen with navigation options
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipal Reporter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Report Municipal Issues',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Help improve your community by reporting issues like potholes, broken streetlights, and more.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportIssueScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Report an Issue'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyReportsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('My Reports'),
                style: OutlinedButton.styleFrom(
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

// screens/report_issue_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/issue_report.dart';
import '../services/report_service.dart';
import '../services/location_service.dart';
import 'camera_screen.dart';

/// Screen for creating a new issue report
class ReportIssueScreen extends StatefulWidget {
  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Photo section
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
                        icon: Icon(_imagePath == null 
                          ? Icons.camera_alt 
                          : Icons.camera_alt_outlined),
                        label: Text(_imagePath == null 
                          ? 'Take Photo' 
                          : 'Retake Photo'),
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
                          Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                          Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
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
                      items: IssueCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(category.categoryIcon),
                              const SizedBox(width: 8),
                              Text(category.categoryDisplayName),
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
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// screens/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import '../services/report_service.dart';

/// Camera screen for taking photos
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      
      // Get the reports directory
      final reportsDir = await ReportService.getReportsDirectory();
      
      // Create unique filename
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = path.join(reportsDir.path, fileName);
      
      // Take picture
      final image = await _controller.takePicture();
      
      // Move file to reports directory
      await File(image.path).copy(imagePath);
      await File(image.path).delete();
      
      // Return the image path
      Navigator.pop(context, imagePath);
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Photo'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: _takePicture,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// screens/my_reports_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/issue_report.dart';
import '../services/report_service.dart';

/// Screen to display all user reports and their status
class MyReportsScreen extends StatefulWidget {
  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<IssueReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await ReportService.getAllReports();
      setState(() {
        _reports = reports.reversed.toList(); // Show newest first
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No reports yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Reports you submit will appear here',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return ReportCard(
                        report: report,
                        onTap: () => _showReportDetails(report),
                      );
                    },
                  ),
                ),
    );
  }

  void _showReportDetails(IssueReport report) {
    showDialog(
      context: context,
      builder: (context) => ReportDetailsDialog(report: report),
    );
  }
}

/// Widget to display individual report card
class ReportCard extends StatelessWidget {
  final IssueReport report;
  final VoidCallback onTap;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    report.category.categoryIcon,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: report.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      report.statusDisplayName,
                      style: TextStyle(
                        color: report.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.categoryDisplayName,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(report.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog to show full report details
class ReportDetailsDialog extends StatelessWidget {
  final IssueReport report;

  const ReportDetailsDialog({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    report.category.categoryIcon,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: report.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: report.statusColor),
                          ),
                          child: Text(
                            report.statusDisplayName,
                            style: TextStyle(
                              color: report.statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Photo
                    if (File(report.imagePath).existsSync()) ...[
                      const Text(
                        'Photo:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(report.imagePath),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Category
                    const Text(
                      'Category:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(report.categoryDisplayName),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Description:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(report.description),
                    
                    const SizedBox(height: 16),
                    
                    // Location
                    const Text(
                      'Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Latitude: ${report.latitude}'),
                    Text('Longitude: ${report.longitude}'),
                    
                    const SizedBox(height: 16),
                    
                    // Date
                    const Text(
                      'Submitted:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat('MMMM dd, yyyy at hh:mm a').format(report.createdAt)),
                    
                    const SizedBox(height: 16),
                    
                    // Report ID
                    const Text(
                      'Report ID:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      report.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
                        