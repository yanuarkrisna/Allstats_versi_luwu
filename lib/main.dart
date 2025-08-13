import 'package:flutter/material.dart';
import 'package:luwu_stats/homepage/homepage.dart';

void main() {
  runApp(const AllStatsApp());
}

class AllStatsApp extends StatelessWidget {
  const AllStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Stats - BPS Kabupaten Luwu',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: const Homepage(),
    );
  }
}
