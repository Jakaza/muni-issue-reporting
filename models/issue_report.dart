import 'dart:convert';

import 'package:flutter/material.dart';

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
