import 'package:flutter/material.dart';

class BatsmenWidget extends StatefulWidget {
  final List<Map<String, dynamic>> selectedBatters;

  BatsmenWidget({required this.selectedBatters});

  @override
  State<BatsmenWidget> createState() => _BatsmenWidgetState();
}

class _BatsmenWidgetState extends State<BatsmenWidget> {

  void updateBatterStats(String batterName, int runs, {bool addBall = true}) {
    setState(() {
      for (var batter in widget.selectedBatters) {
        if (batter['name'] == batterName) {
          // Update runs
          batter['r'] += runs;

          // Increment the ball count only if it's not a wide or no-ball
          if (addBall) {
            batter['b'] += 1;
          }

          // Increment the 4s or 6s count if applicable
          if (runs == 4) {
            batter['4s'] = (batter['4s'] ?? 0) + 1;
          } else if (runs == 6) {
            batter['6s'] = (batter['6s'] ?? 0) + 1;
          }

          // Calculate the strike rate
          batter['sr'] = (batter['b'] > 0)
              ? (batter['r'] / batter['b']) * 100
              : 0.0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 20,
      headingRowColor: MaterialStateProperty.all(Colors.green),
      columns: [
        DataColumn(
          label: Padding(
            padding: EdgeInsets.only(right: 140),
            child: Text(
              'Batter',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        DataColumn(label: Text('R', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('B', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('4s', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('6s', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Text('SR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
      rows: widget.selectedBatters.map((batter) {
        return DataRow(
          cells: [
            DataCell(Text(batter['name'])),
            DataCell(Text(batter['r'].toString())),
            DataCell(Text(batter['b'].toString())),
            DataCell(Text((batter['4s'] ?? 0).toString())), // Safeguard against null
            DataCell(Text((batter['6s'] ?? 0).toString())), // Safeguard against null
            DataCell(Text(batter['sr'].toStringAsFixed(1))),
          ],
        );
      }).toList(),
    );
  }
}
