import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/database/match_model.dart';
import 'package:pavilion_scorefy/screens/create_match.dart';
import 'package:pavilion_scorefy/screens/manage_your_players.dart';
import 'package:pavilion_scorefy/screens/manage_your_teams.dart';
import 'package:pavilion_scorefy/screens/new_tournaments.dart';
import 'package:pavilion_scorefy/screens/player_statistics.dart';
import 'package:pavilion_scorefy/screens/scoreboard/score_board.dart';
import 'package:pavilion_scorefy/screens/teams/standings/team_standings.dart';
import 'package:pavilion_scorefy/screens/widget/datadialog.dart';

import '../database/db_helper.dart';
import '../database/players_model.dart';
import '../database/scoreboard_model.dart';
import '../database/team_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MatchModel? ongoingMatch;
  List<Team> teams = [];
  bool isMatchOngoing = false;
  int overs = 1;
  int players = 2;
  String? selectedTeamA;
  String? selectedTeamB;
  String? selectedBatter1; // Track selected batter 1
  String? selectedBatter2; // Track selected batter 2
  String? selectedBowler;

  @override
  void initState() {
    super.initState();
    _loadOngoingMatch();
  }

  void _loadOngoingMatch() async {
    // Fetch the match as a map
    // final matchMap = await DatabaseHelper().fetchOngoingMatch();
    final match = await DatabaseHelper().fetchOngoingMatch();
    setState(() {
      ongoingMatch = match;
    });
    // Ensure the map is converted to a MatchModel
    // setState(() {
    //   ongoingMatch = MatchModel.fromMap(matchMap as Map<String, dynamic>); // Convert the map to MatchModel
    // });

    if (ongoingMatch != null) {
      print("Ongoing Match Loaded: ");
      print("Match ID: ${ongoingMatch!.id}");
      print("Team A: ${ongoingMatch!.teamA}");
      print("Team B: ${ongoingMatch!.teamB}");
      print("Overs: ${ongoingMatch!.overs}");
      print("Players: ${ongoingMatch!.players}");
      print("Target: ${ongoingMatch!.score}");
      print("Wickets: ${ongoingMatch!.wickets}");
      print("Extras: ${ongoingMatch!.extras}");
      print("Batters: ${ongoingMatch!.batters}");
      print("Bowlers: ${ongoingMatch!.bowlers}");
      print("Match On Going: ${ongoingMatch!.isMatchOngoing}");
    } else {
      print("No ongoing match found.");
    }
  }

  void _resumeMatch() async {
    if (ongoingMatch != null) {
      final match = ongoingMatch!; // Use the ongoing match details

      // Fetch match details using the match id from the database
      final dbHelper = DatabaseHelper();
      final matchDetails = await dbHelper.fetchMatchById(match.id);

      if (matchDetails != null) {
        // Use the fetched team names from match details
        String teamAName = matchDetails.teamA; // Use key to access the value
        String teamBName = matchDetails.teamB; // Use key to access the value

        // Fetch the actual team objects based on the team names
        // Team teamA = teams.firstWhere(
        //   (team) => team.teamName == teamAName,
        //   orElse: () =>
        //       Team(id: -1, teamName: 'Unknown', logo: 'assets/team.jpg'),
        // );
        //
        // Team teamB = teams.firstWhere(
        //   (team) => team.teamName == teamBName,
        //   orElse: () =>
        //       Team(id: -1, teamName: 'Unknown', logo: 'assets/team.jpg'),
        // );
        //
        // // Check if both teams were found and are valid
        // if (teamA.id != -1 && teamB.id != -1) {
        //   final playersTeamA = await dbHelper
        //       .getPlayersByTeamId(teamA.id!); // Fetch players of Team A
        //   final playersTeamB = await dbHelper
        //       .getPlayersByTeamId(teamB.id!); // Fetch players of Team B

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreboardScreen(
                database: dbHelper,
                data: ScoreboardScreenData(
                  matchId: match.id.toString(),
                  // Pass the ongoing match ID
                  teamA: teamAName,
                  teamB: teamBName,
                  overs: match.overs,
                  players: match.players,
                  teamALogo: 'assets/logo.png',
                  teamBLogo: 'assets/logo.png',
                  playersTeamA: playersTeamA,
                  playersTeamB: playersTeamB,
                  selectedBatter1: selectedBatter1,
                  selectedBatter2: selectedBatter2,
                  selectedBowler: selectedBowler,
                ),
              ),
            ),
          );
        // } else {
        //   print("Could not find the teams or team names.");
        // }
      } else {
        print("No match details found for match ID ${match.id}");
      }
    } else {
      print("No ongoing match to resume.");
    }
  }

  List<Player> playersTeamA = [
    Player(id: 1, name: 'Player A1', isAvailable: false),
    Player(id: 2, name: 'Player A2', isAvailable: false),
  ];

  List<Player> playersTeamB = [
    Player(id: 3, name: 'Player B1', isAvailable: false),
    Player(id: 4, name: 'Player B2', isAvailable: false),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the column in SingleChildScrollView
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        // Add bouncing scroll physics here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  style: ElevatedButton.styleFrom(),
                  onPressed: _loadOngoingMatch,
                  icon: Icon(Icons.download, color: Colors.green),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png', // Replace with your logo path
                      height: size.height * 0.2,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Own Cricket Scoring App',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Resume Match Button
              ElevatedButton(
                onPressed: ongoingMatch != null ? () => _resumeMatch() : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 100),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'RESUME MATCH',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Grid Menu Options
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  _buildGridItem(
                    icon: Icons.sports_cricket,
                    label: 'New Match',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateMatchScreen()));
                    },
                    color: Colors.amber,
                  ),
                  _buildGridItem(
                    icon: Icons.emoji_events,
                    label: 'New Tournament',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewTournamentScreen()));
                    },
                    color: Colors.red,
                  ),
                  _buildGridItem(
                    icon: Icons.group,
                    label: 'Manage Teams',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageTeamsScreen()));
                    },
                    color: Colors.brown,
                  ),
                  _buildGridItem(
                    icon: Icons.person,
                    label: 'Manage Players',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManagePlayersScreen()));
                    },
                    color: Colors.teal,
                  ),
                  _buildGridItem(
                    icon: Icons.stacked_bar_chart,
                    label: 'Players Statistics',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlayerStatisticsScreen()));
                    },
                    color: Colors.green,
                  ),
                  _buildGridItem(
                    icon: Icons.table_chart,
                    label: 'Teams Standings',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TeamStandingsScreen()));
                    },
                    color: Colors.deepPurple,
                  ),
                  _buildGridItem(
                    icon: Icons.sports_score,
                    label: 'Career Mode',
                    onTap: _showCareerModeDialog,
                    color: Colors.green,
                    pro: true,
                  ),
                  _buildGridItem(
                    icon: Icons.backup,
                    label: 'Backup Data',
                    onTap: () => showManageDataDialog(context),
                    color: Colors.pink,
                  ),
                ],
              ),
              SizedBox(
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the Career Mode confirmation dialog
  void _showCareerModeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
              "Are you sure you want to switch to BASIC version? Switching to BASIC version will reset your older data and settings."),
          actions: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build each grid item
  Widget _buildGridItem({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    bool pro = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (pro)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
