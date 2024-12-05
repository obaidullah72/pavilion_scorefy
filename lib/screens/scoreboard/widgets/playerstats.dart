import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/batsmenwidget.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/bowlerwidget.dart';

class PlayerStatsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> batters;
  final List<Map<String, dynamic>> bowlers;

  PlayerStatsWidget({
    required this.batters,
    required this.bowlers,
  });

  @override
  _PlayerStatsWidgetState createState() => _PlayerStatsWidgetState();
}

class _PlayerStatsWidgetState extends State<PlayerStatsWidget> {
  // late List<Map<String, dynamic>> _selectedBowlers;

  @override
  void initState() {
    super.initState();
    // _selectedBowlers = widget.bowlers; // Initialize bowlers
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Batting Stats Section
        Container(
          width: MediaQuery.of(context).size.width,
          child: BatsmenWidget(selectedBatters: widget.batters),
        ),
        SizedBox(height: 16), // Space between batters and bowlers section
        // Bowling Stats Section
        Container(
          width: MediaQuery.of(context).size.width,
          child: BowlerWidget(
            selectedBowlers:widget.bowlers, // Pass the current list of bowlers
          ),
        ),
      ],
    );
  }
}
