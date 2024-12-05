import 'package:flutter/material.dart';

class BowlerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> selectedBowlers;

  const BowlerWidget({super.key, required this.selectedBowlers});

  @override
  State<BowlerWidget> createState() => _BowlerWidgetState();
}

class _BowlerWidgetState extends State<BowlerWidget> {

  void updateBowlerStats(String bowlerName, int runs,
      {bool isWicket = false, bool isNoBall = false, bool isWide = false, bool isBoundary = false, bool isSix = false}) {
    setState(() {
      for (var bowler in widget.selectedBowlers) {
        if (bowler['name'] == bowlerName) {
          if (isWide || isNoBall) {
            bowler['r'] += runs;
          } else {
            bowler['r'] += runs;
            bowler['balls'] = (bowler['balls'] ?? 0) + 1;

            if (isBoundary) {
              bowler['r'] += 4;
            }

            if (isSix) {
              bowler['r'] += 6;
            }
          }

          if (isWicket) {
            bowler['w'] = (bowler['w'] ?? 0) + 1;
          }

          int balls = bowler['balls'] ?? 0;
          int overs = balls ~/ 6;
          int remainderBalls = balls % 6;

          bowler['o'] = overs + (remainderBalls > 0 ? (remainderBalls / 6.0) : 0.0);  // Store overs with decimal value
          if (bowler['o'] == overs && balls > 0) {
            bowler['o'] = overs + (balls / 6.0); // Store overs with decimal value
          }

          if (bowler['o'] > 0) {
            bowler['econ'] = bowler['r'] / bowler['o']; // Runs / Overs
          } else {
            bowler['econ'] = 0.0; // Prevent division by zero
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 20,
      headingRowColor: WidgetStateProperty.all(Colors.green),
      columns: [
        DataColumn(
          label: Padding(
            padding: EdgeInsets.only(right: 120),
            child: Text(
              'Bowler',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        DataColumn(label: Text('O', style: TextStyle(fontWeight: FontWeight.bold))), // Overs
        DataColumn(label: Text('R', style: TextStyle(fontWeight: FontWeight.bold))), // Runs
        DataColumn(label: Text('W', style: TextStyle(fontWeight: FontWeight.bold))), // Wickets
        // DataColumn(label: Text('NB', style: TextStyle(fontWeight: FontWeight.bold))), // No Balls
        DataColumn(label: Text('Eco', style: TextStyle(fontWeight: FontWeight.bold))), // Economy rate
      ],
      rows: widget.selectedBowlers.map((bowler) {
        return DataRow(
          cells: [
            DataCell(Text(bowler['name'] ?? 'Unknown')), // Fallback for null name
            DataCell(Text((bowler['o'] ?? 0.0).toStringAsFixed(1))), // Overs
            DataCell(Text((bowler['r'] ?? 0).toString())), // Runs
            DataCell(Text((bowler['w'] ?? 0).toString())), // Wickets
            // DataCell(Text((bowler['noBalls'] ?? 0).toString())), // No Balls
            DataCell(Text((bowler['econ'] ?? 0.0).toStringAsFixed(1))),
          ],
        );
      }).toList(),
    );
  }
}
