import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';

class TeamStandingsScreen extends StatefulWidget {
  @override
  _TeamStandingsScreenState createState() => _TeamStandingsScreenState();
}

class _TeamStandingsScreenState extends State<TeamStandingsScreen> {
  List<Map<String, dynamic>> teamsPerformance = [];

  bool sortAscending = true;
  int sortColumnIndex = 0;

  Future<void> _loadTeamPerformance() async {
    List<Map<String, dynamic>> teamStats = await DatabaseHelper().getAllTeamsWithPerformance();
    setState(() {
      teamsPerformance = teamStats;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTeamPerformance();
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> team) getField, int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
      teamsPerformance.sort((a, b) {
        if (!ascending) {
          final Map<String, dynamic> c = a;
          a = b;
          b = c;
        }
        return Comparable.compare(getField(a), getField(b));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Team's Standings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.green),
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            columns: [
              DataColumn(
                label: Text('Team Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                onSort: (index, ascending) => _sort((team) => team['winPercentage'], index, ascending),
              ),
              DataColumn(
                label: Text('Matches', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                numeric: true,
                onSort: (index, ascending) => _sort((team) => team['matches'], index, ascending),
              ),
              DataColumn(
                label: Text('Won', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                numeric: true,
                onSort: (index, ascending) => _sort((team) => team['won'], index, ascending),
              ),
              DataColumn(
                label: Text('Lost', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                numeric: true,
                onSort: (index, ascending) => _sort((team) => team['lost'], index, ascending),
              ),
              DataColumn(
                label: Text('Tied', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                numeric: true,
                onSort: (index, ascending) => _sort((team) => team['tied'], index, ascending),
              ),
              DataColumn(
                label: Text('Win %', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                numeric: true,
                onSort: (index, ascending) => _sort((team) => team['winPercentage'], index, ascending),
              ),
            ],
            rows: List.generate(
              teamsPerformance.length,
                  (index) {
                final team = teamsPerformance[index];
                return DataRow(
                  cells: [
                    DataCell(Text(team['teamName'])),
                    DataCell(Text(team['matches'].toString())),
                    DataCell(Text(team['won'].toString())),
                    DataCell(Text(team['lost'].toString())),
                    DataCell(Text(team['tied'].toString())),
                    DataCell(Text(team['winPercentage'].toStringAsFixed(2))),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
