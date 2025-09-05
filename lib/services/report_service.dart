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
  static Future<bool> updateReportStatus(
    String reportId,
    ReportStatus newStatus,
  ) async {
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
    // print('Status: ${report.statusDisplayName}');
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
