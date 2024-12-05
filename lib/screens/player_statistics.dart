import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/players_model.dart';

class PlayerStatisticsScreen extends StatefulWidget {
  @override
  _PlayerStatisticsScreenState createState() => _PlayerStatisticsScreenState();
}

class _PlayerStatisticsScreenState extends State<PlayerStatisticsScreen> {
  late Future<List<Player>> players;

  @override
  void initState() {
    super.initState();
    players = fetchPlayers(); // Fetch players when the screen is initialized
  }

  Future<List<Player>> fetchPlayers() async {
    // Fetch all players from the database
    var data = await DatabaseHelper.instance.getAllPlayers();
    print("Fetched Players: $data"); // Debugging line
    return data.map((player) {
      return Player.fromMap(player); // Convert the Map to Player
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: Text('Player Statistics'),
          bottom: TabBar(
            labelColor: Colors.white, // Active tab color
            unselectedLabelColor: Colors.white70, // Inactive tab color
            dividerColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Batting'),
              Tab(text: 'Bowling'),
              Tab(text: 'Statistics'),
            ],
          ),
        ),
        body: FutureBuilder<List<Player>>(
          future: players,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No players available'));
            } else {
              List<Player> playersList = snapshot.data!;

              // Additional null check before using the players data
              if (playersList.any((player) => player.mat == null || player.avg == null)) {
                return Center(child: Text('Some player data is missing.'));
              }

              return TabBarView(
                children: [
                  buildStatisticsTable(playersList, 'Batting'),
                  buildBowlingStatisticsTable(playersList, 'Bowling'),
                  Center(child: Text('General Statistics (Not Available)')),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Batting statistics table
  Widget buildStatisticsTable(List<Player> players, String category) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('Player Name')),
          DataColumn(label: Text('MAT')),
          DataColumn(label: Text('NO')),
          DataColumn(label: Text('Runs')),
          DataColumn(label: Text('AVG')),
          DataColumn(label: Text('S/R')),
        ],
        rows: players.map((player) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(player.name ?? 'Unknown')),
              DataCell(Text(player.mat?.toString() ?? '0')),
              DataCell(Text(player.no?.toString() ?? '0')),
              DataCell(Text(player.runs?.toString() ?? '0')),
              DataCell(Text(player.avg?.toString() ?? '0.0')),
              DataCell(Text(player.sr?.toString() ?? '0.0')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Bowling statistics table
  Widget buildBowlingStatisticsTable(List<Player> players, String category) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('Player Name')),
          DataColumn(label: Text('MAT')),
          DataColumn(label: Text('Runs')),
          DataColumn(label: Text('WKTS')),
          DataColumn(label: Text('BBM')),
          DataColumn(label: Text('AVG')),
          DataColumn(label: Text('ECO')),
        ],
        rows: players.map((player) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(player.name ?? 'Unknown')),
              DataCell(Text(player.mat?.toString() ?? '0')),
              DataCell(Text(player.runs?.toString() ?? '0')),
              DataCell(Text(player.wkts?.toString() ?? '0')),
              DataCell(Text(player.bbm ?? '0/0')),
              DataCell(Text(player.bowlingavg?.toString() ?? '0.0')),
              DataCell(Text(player.eco?.toString() ?? '0.0')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
