import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/create_match.dart';
import 'package:pavilion_scorefy/screens/manage_your_players.dart';
import 'package:pavilion_scorefy/screens/manage_your_teams.dart';
import 'package:pavilion_scorefy/screens/new_tournaments.dart';
import 'package:pavilion_scorefy/screens/player_statistics.dart';
import 'package:pavilion_scorefy/screens/scoreboard/score_board.dart';
import 'package:pavilion_scorefy/screens/teams/standings/team_standings.dart';
import 'package:pavilion_scorefy/screens/widget/datadialog.dart';

import '../database/players_model.dart';
import '../database/scoreboard_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMatchOngoing = false;

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
              // Conditional button for "Resume Match" or "New Match"
              isMatchOngoing
                  ? ElevatedButton(
                onPressed: () {
                  ScoreboardScreenData data = ScoreboardScreenData(
                    teamA: 'Team A',
                    teamB: 'Team B',
                    overs: 20,
                    players: 11,
                    teamALogo: 'assets/logo.png',
                    teamBLogo: 'assets/logo.png',
                    playersTeamA: playersTeamA,
                    playersTeamB: playersTeamB,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreboardScreen(data: data, ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 100),
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
              )
                  : ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateMatchScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 100),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'NEW MATCH',
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
                // 3 columns
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: NeverScrollableScrollPhysics(),
                // Disable GridView scrolling
                shrinkWrap: true,
                // Let the GridView take only as much space as needed
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
                  // _buildGridItem(
                  //   icon: Icons.upload_file,
                  //   label: 'Load Tournament',
                  //   onTap: () {},
                  //   color: Colors.blue,
                  // ),
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
                    // Show dialog on tap
                    color: Colors.green,
                    pro: true,
                  ),
                  _buildGridItem(
                    icon: Icons.backup,
                    label: 'Backup Data',
                    onTap: () => showManageDataDialog(context), // Call Manage Data dialog here
                    color: Colors.pink,
                  ),
                ],
              ),
              SizedBox(
                height: 150,
              )
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
                  // Add logic here if user confirms (e.g., switch to basic version)
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
