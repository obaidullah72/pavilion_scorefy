import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/teams/addoreditteams.dart';
import 'package:pavilion_scorefy/screens/teams/players/players_selection.dart';
import '../database/db_helper.dart';
import '../database/team_model.dart';
import '../database/players_model.dart';

class ManageTeamsScreen extends StatefulWidget {
  @override
  _ManageTeamsScreenState createState() => _ManageTeamsScreenState();
}

class _ManageTeamsScreenState extends State<ManageTeamsScreen> {
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    _fetchTeams(); // Load teams from the database
  }

  // Fetch teams from the database
  void _fetchTeams() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      List<Team> fetchedTeams = await dbHelper.getAllTeams();
      for (var team in fetchedTeams) {
        // Fetch players for each team
        List<Player> players =
            await dbHelper.getPlayersByTeamId(team.id!);
        team.players = players; // Add the players to the team object
      }
      setState(() {
        teams = fetchedTeams;
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  void _deleteTeam(int index) async {
    final dbHelper = DatabaseHelper.instance;
    try {
      // Step 1: Fetch all players of the team before deletion
      List<Player> players = await dbHelper.getPlayersByTeamId(teams[index].id!);

      // Step 2: Update players' availability
      for (var player in players) {
        player.isAvailable = true; // Set players as available again
        await dbHelper.updatePlayerAvailability(player); // Update in database
      }

      // Step 3: Delete the team from the database
      await dbHelper.deleteTeam(teams[index].id!); // Delete from database

      // Step 4: Remove the team from the local list
      setState(() {
        teams.removeAt(index);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Team has been Deleted and players are now available",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 1,
          margin: EdgeInsets.all(10),
          behavior: SnackBarBehavior.floating, // Adjust the behavior to floating
        ),
      );
    } catch (e) {
      print('Error deleting team: $e');
    }
  }


  // Function to handle editing team (navigates to edit screen)
  void _editTeam(int index) {
    Team teamToEdit = teams[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTeamScreen(team: teamToEdit),
      ),
    ).then((_) {
      _fetchTeams(); // Refresh the team list after editing
    });
  }

  void _viewPlayers(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerSelectionScreen(
          teamName: teams[index].teamName,
          teamLogoUrl: teams[index].logo,
          teamid: teams[index].id,
          onPlayersUpdated: (updatedPlayers) {
            setState(() {
              teams[index].players =
                  updatedPlayers; // Update the player's list in the team model
            });
          },
        ),
      ),
    ).then((_) {
      _fetchTeams(); // Ensure the team list is refreshed after returning
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text('Manage Your Teams'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditTeamScreen(),
                ),
              ).then((_) {
                _fetchTeams(); // Refresh the team list
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 30.0,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'TEAM NAME',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'PLAYERS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTION',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: List<DataRow>.generate(
              teams.length,
              (index) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(teams[index].teamName)),
                  DataCell(Text(
                    teams[index].players?.length.toString() ?? '0',
                  )),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.group, color: Colors.green),
                          onPressed: () => _viewPlayers(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _editTeam(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTeam(index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
