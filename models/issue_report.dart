import 'dart:convert';

enum IssueCategory {
  water,
  electricity,
  potholes,
  waste,
  streetlights,
  publicSafety,
  parks,
  other,
}

enum ReportStatus { submitted, inProgress, resolved, rejected }

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
        (e) => e.toString().split('.').last == json['category'],
      ),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
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
}
