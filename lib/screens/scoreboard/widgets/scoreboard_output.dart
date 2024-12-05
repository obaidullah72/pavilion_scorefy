import 'dart:io';

import 'package:flutter/material.dart';

class ScoreboardWidget extends StatelessWidget {
  final int score;
  final int wickets;
  final int extras;
  final double crr; // Current run rate
  final int target; // Target score
  final int inning; // Current inning number
  final VoidCallback onInningsEnd; // Callback for ending the innings
  final String teamA;
  final String teamB;
  final String teamALogo;
  final String teamBLogo;
  final int totalPlayers;

  ScoreboardWidget({
    required this.score,
    required this.wickets,
    required this.extras,
    required this.crr,
    required this.target, // Initialize target
    required this.inning, // Initialize inning
    required this.onInningsEnd, // Initialize the callback
    required this.teamA,
    required this.teamB,
    required this.teamALogo,
    required this.teamBLogo,
     required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    // Determine team details based on the inning
    String currentTeamName = inning == 1 ? teamA : teamB;
    String currentTeamLogo = inning == 1 ? teamALogo : teamBLogo;

    // Check if innings should end
    if (wickets >= 10) {
      // Call the callback function to end the innings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onInningsEnd();
      });
    }

    return Container(
      color: Colors.green,
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Score Row
          if (target > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Target: $target',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Innings Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Innings:',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              SizedBox(width: 4.0),
              Text(
                '$inning', // Display current inning number
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          // Team Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Team: ',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              CircleAvatar(
                radius: 12.0,
                backgroundColor: Colors.grey, // Placeholder for team logo
                backgroundImage: FileImage(File(currentTeamLogo)), // Show current team logo
              ),
              SizedBox(width: 8.0),
              Text(
                currentTeamName, // Display current team name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          // Score and Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extras: $extras', // Display updated extras
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              Text(
                '$score/$wickets', // Display updated score
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'CRR: ${crr.toStringAsFixed(2)}', // Display calculated CRR
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
