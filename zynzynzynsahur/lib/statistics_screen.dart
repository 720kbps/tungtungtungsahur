import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Local state with requested default values
  int _energyDrinks = 8;
  int _beers = 13;
  int _cigarettes = 25;
  String _crashouts = "too many";
  int _reelsScrolledHours = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Statistics",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              "Energy Drinks",
              "$_energyDrinks",
              Icons.bolt,
              Colors.orange,
              () => setState(() => _energyDrinks++),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              "Beers",
              "$_beers",
              Icons.sports_bar,
              Colors.amber,
              () => setState(() => _beers++),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              "Cigarettes",
              "$_cigarettes",
              Icons.smoking_rooms,
              Colors.blueGrey,
              () => setState(() => _cigarettes++),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              "Crashouts",
              _crashouts,
              Icons.warning_amber_rounded,
              Colors.redAccent,
              () => setState(() => _crashouts = "even more"),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              "Reels Scrolled",
              "$_reelsScrolledHours hours",
              Icons.video_library_outlined,
              Colors.purpleAccent,
              () => setState(() => _reelsScrolledHours++),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Keep track of your daily intake",
                style: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, VoidCallback onAdd) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle, color: Colors.black, size: 32),
          ),
        ],
      ),
    );
  }
}
