import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/scoreboard/score_board.dart';
import '../database/db_helper.dart';
import '../database/scoreboard_model.dart';
import '../database/team_model.dart';

class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  int overs = 1;
  int players = 2;
  String? selectedTeamA;
  String? selectedTeamB;
  String? selectedBatter1; // Track selected batter 1
  String? selectedBatter2; // Track selected batter 2
  String? selectedBowler;
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  void _fetchTeams() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      List<Team> fetchedTeams = await dbHelper.getAllTeams();
      setState(() {
        teams = fetchedTeams;
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  void _incrementOvers() {
    setState(() {
      overs++;
    });
  }

  void _decrementOvers() {
    if (overs > 1) {
      setState(() {
        overs--;
      });
    }
  }

  void _incrementPlayers() {
    if (players < 11) {
      setState(() {
        players++;
      });
    }
  }

  void _decrementPlayers() {
    if (players > 2) {
      setState(() {
        players--;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Filter available teams for Team A and Team B dynamically
    List<Team> availableTeamsForA =
    teams.where((team) => team.teamName != selectedTeamB).toList();
    List<Team> availableTeamsForB =
    teams.where((team) => team.teamName != selectedTeamA).toList();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Create New Match'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. of Overs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrementOvers,
                  color: Colors.green,
                ),
                Text('$overs', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _incrementOvers,
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('No. of Players',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrementPlayers,
                  color: Colors.green,
                ),
                Text('$players', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _incrementPlayers,
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Select Team A',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedTeamA,
              hint: Text("Select Team"),
              isExpanded: true,
              items: availableTeamsForA.map((Team team) {
                return DropdownMenuItem<String>(
                  value: team.teamName,
                  child: Text(team.teamName),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedTeamA = value;
                  // Reset Team B if Team A is selected to avoid conflicts
                  if (selectedTeamB == value) {
                    selectedTeamB = null;
                  }
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Team B',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedTeamB,
              hint: Text("Select Team"),
              isExpanded: true,
              items: availableTeamsForB.map((Team team) {
                return DropdownMenuItem<String>(
                  value: team.teamName,
                  child: Text(team.teamName),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedTeamB = value;
                  // Reset Team A if Team B is selected to avoid conflicts
                  if (selectedTeamA == value) {
                    selectedTeamA = null;
                  }
                });
              },
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (selectedTeamA != null && selectedTeamB != null) {
                    final teamA = teams
                        .firstWhere((team) => team.teamName == selectedTeamA);
                    final teamB = teams
                        .firstWhere((team) => team.teamName == selectedTeamB);

                    if (teamA.id != null && teamB.id != null) {
                      final dbHelper = DatabaseHelper.instance;
                      final playersTeamA = await dbHelper.getPlayersByTeamId(
                          teamA.id!); // Force unwrap since it's checked
                      final playersTeamB = await dbHelper.getPlayersByTeamId(
                          teamB.id!); // Force unwrap since it's checked

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreboardScreen(
                            database: DatabaseHelper.instance,
                            data: ScoreboardScreenData(
                              teamA: selectedTeamA!,
                              teamB: selectedTeamB!,
                              overs: overs,
                              players: players,
                              teamALogo: teamA.logo,
                              teamBLogo: teamB.logo,
                              playersTeamA: playersTeamA,
                              playersTeamB: playersTeamB,
                              selectedBatter1: selectedBatter1,
                              selectedBatter2: selectedBatter2,
                              selectedBowler: selectedBowler,
                            ),
                          ),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.green,
                          title: Text('Error',
                              style: TextStyle(color: Colors.white)),
                          content: Text('One or both teams have invalid IDs.',
                              style: TextStyle(color: Colors.white)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.green,
                        title: Text('Alert',
                            style: TextStyle(color: Colors.white)),
                        content: Text('Please select both teams.',
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
