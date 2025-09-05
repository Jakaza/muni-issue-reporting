import 'package:flutter/material.dart';
import 'package:muni/screens/report_issue_screen.dart';
import 'package:muni/screens/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipal Reporter'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Icon
          Icon(Icons.location_city, size: 100, color: Colors.blue),
          const SizedBox(height: 32),
          const Text(
            'Report Municipal Issues',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Help improve your community by reporting issues like potholes, broken streetlights, and more.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportIssueScreen()),
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
                  MaterialPageRoute(builder: (context) => MyReportsScreen()),
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
    );
  }
}
