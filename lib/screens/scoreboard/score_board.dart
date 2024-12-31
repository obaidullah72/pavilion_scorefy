import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/home_screen.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/batter_bowler_dialog.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/over_board.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/playerstats.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/score_input_board.dart';
import 'package:pavilion_scorefy/screens/scoreboard/widgets/scoreboard_output.dart';
import '../../database/db_helper.dart';
import '../../database/match_model.dart';
import '../../database/scoreboard_model.dart';

class ScoreboardScreen extends StatefulWidget {
  final ScoreboardScreenData data;

  final DatabaseHelper? database;
  final String? teamAPlayer;
  final String? teamBPlayer;
  final List<Map<String, dynamic>>? initialBatters;
  final List<Map<String, dynamic>>? initialBowlers;

  ScoreboardScreen({
    required this.data,
    this.database,
    this.teamAPlayer,
    this.teamBPlayer,
    this.initialBatters,
    this.initialBowlers,
  });

  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  // Stream controllers for batters and bowlers
  final StreamController<List<Map<String, dynamic>>> _batterStreamController =
      StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>> _bowlerStreamController =
      StreamController.broadcast();

  double _calculateStrikeRate(int runs, int balls) {
    return balls > 0 ? (runs / balls) * 100 : 0.0;
  }

  double _calculateEconomyRate(int runs, double overs) {
    return overs > 0 ? runs / overs : 0.0;
  }

  void endMatch(String teamA, String teamB, String outcome) async {
    final dbHelper = DatabaseHelper();

    await dbHelper.updateMatchOutcome(teamA, teamB, outcome);

    print("Match outcome updated successfully.");
  }

  void _showAddBattersAndBowlerDialog(
      BuildContext context, String battingTeam, String bowlingTeam) async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => SelectBattersAndBowlerDialog(
        database: DatabaseHelper(),
        teamA: battingTeam,
        teamB: bowlingTeam,
        onPlayersSelected: (selectedBatters, selectedBowlers) {
          setState(() {
            // Initialize the batters list with selected players
            batters = selectedBatters.map((batter) {
              return {
                'name': batter['name'], // Access name directly from the map
                'r': 0, // Runs
                'b': 0, // Balls faced
                '4s': 0, // Fours
                '6s': 0, // Sixes
                'sr': 0.0, // Strike rate
              };
            }).toList();

            // Initialize the bowlers list with selected bowlers
            bowlers = selectedBowlers.map((bowler) {
              return {
                'name': bowler['name'], // Access name directly from the map
                'o': 0.0, // Overs
                'r': 0, // Runs conceded
                'w': 0, // Wickets taken
                'nb': 0, // No balls
                'eco': 0.0, // Economy rate
              };
            }).toList();
          });
        },
      ),
    );

    if (result != null) {
      setState(() {
        selectedBatter1 = result['batter1'];
        selectedBatter2 = result['batter2'];
        selectedBowler = result['bowler'];
      });
    }
  }

  void _endMatch() {
    // Determine match outcome
    String outcome;
    if (score >= targetScore) {
      outcome = '$teamB won by chasing the target of $targetScore';
    } else {
      outcome = '$teamA won by defending the target of $targetScore';
    }

    // Update the match outcome in the database
    endMatch(teamA, teamB, outcome);
  }

  void _updatePlayerStats({
    required String playerName,
    required String playerType, // 'batter' or 'bowler'
    int runs = 0,
    bool isWicket = false,
    bool isNoBall = false,
    bool addBall = true,
  }) {
    setState(() {
      final playerList = playerType == 'batter' ? batters : bowlers;
      final player = playerList.firstWhere((p) => p['name'] == playerName);

      if (playerType == 'batter') {
        player['r'] += runs;
        if (addBall) player['b'] += 1;
        if (runs == 4) player['4s'] += 1;
        if (runs == 6) player['6s'] += 1;
        player['sr'] = _calculateStrikeRate(player['r'], player['b']);
      } else if (playerType == 'bowler') {
        player['r'] += runs;
        if (!isNoBall) player['balls'] += 1;
        player['o'] = (player['balls'] ~/ 6) + (player['balls'] % 6) / 10.0;
        if (isWicket) player['w'] += 1;
        player['econ'] = _calculateEconomyRate(player['r'], player['o']);
      }

      // Update stream
      (playerType == 'batter'
              ? _batterStreamController
              : _bowlerStreamController)
          .add(playerList);
    });
  }

  // Update batter stats
  void _updateBatterStats(String batterName, int runs, {bool addBall = true}) {
    setState(() {
      for (var batter in batters) {
        if (batter['name'] == batterName) {
          batter['r'] += runs;
          if (addBall) batter['b'] += 1;
          if (runs == 4) batter['4s'] += 1;
          if (runs == 6) batter['6s'] += 1;
          batter['sr'] = _calculateStrikeRate(batter['r'], batter['b']);
        }
      }
      _batterStreamController.add(batters);
    });
  }

  void onMatchEnd(int teamAWins, int teamBWins, int teamAId, int teamBId) {
    bool isTeamAWin = teamAWins > teamBWins;
    bool isTie = teamAWins == teamBWins;

    // Update team points for Team A
    DatabaseHelper().updateTeamPoints(teamAId, isTeamAWin, isTie);

    // Update team points for Team B
    DatabaseHelper().updateTeamPoints(teamBId, !isTeamAWin, isTie);

    // Navigate to Home Page
    Navigator.of(context).pop(); // Close current screen
    Navigator.of(context).pop(); // Go to Home Page
  }

  // Update bowler stats
  void _updateBowlerStats(String bowlerName,
      {int runs = 0, bool isWicket = false, bool isNoBall = false}) {
    setState(() {
      final bowler = bowlers.firstWhere((b) => b['name'] == bowlerName);
      bowler['r'] += runs;
      if (!isNoBall) bowler['balls'] += 1;
      bowler['o'] = (bowler['balls'] ~/ 6) + (bowler['balls'] % 6) / 10.0;
      if (isWicket) bowler['w'] += 1;
      bowler['econ'] = _calculateEconomyRate(bowler['r'], bowler['o']);
      _bowlerStreamController.add(bowlers);
    });
  }

  late String teamA;
  late String teamB;
  bool isLoading = true;
  late int overs;
  late int players;
  late String teamALogo;
  late String teamBLogo;
  int score = 0;
  int wickets = 0;
  int balls = 0;
  int completedOvers = 0;
  int playerout = 0;
  int currentOverBalls = 0;
  int extras = 0;
  int currentInning = 1;
  bool inningsEnded = false;

  double get currentrunrate => (balls > 0) ? (score / balls) * 6 : 0.0;
  List<int> ballOutcomes = [];
  String teamName = "Pak Tigers";
  int targetScore = 0;

  List<Map<String, dynamic>> batters = [];
  List<Map<String, dynamic>> bowlers = [];

  List<String> teamAPlayers = [];
  List<String> teamBPlayers = [];

  String? selectedBatter1;
  String? selectedBatter2;
  String? selectedBowler;


  // Function to simulate updating match in the database
  Future<void> updateMatchInDatabase() async {
    // Simulate the database update (Replace with actual DB logic)
    await Future.delayed(Duration(seconds: 5));

    // Once the match is updated, show a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Match has been updated in the database'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
  }
  void _updateBalls({bool countBall = true}) {
    if (!countBall || inningsEnded) return; // Prevent ball update if innings ended

    if (countBall) {
      setState(() {
        balls += 1;
        currentOverBalls += 1;

        // Ensure the selected players are valid
        if (selectedBatter1 != null &&
            !teamAPlayers.contains(selectedBatter1)) {
          selectedBatter1 = null; // Reset to null if player no longer exists
        }

        if (selectedBatter2 != null &&
            !teamAPlayers.contains(selectedBatter2)) {
          selectedBatter2 = null; // Reset to null if player no longer exists
        }

        if (selectedBowler != null && !teamAPlayers.contains(selectedBowler)) {
          selectedBowler = null; // Reset to null if player no longer exists
        }

        // End innings immediately if overs are 0
        if (overs == 0) {
          inningsEnded = true;
          _endInnings();
          return; // Exit early if overs is 0, no need to process further
        }

        if (currentOverBalls == 6 && !inningsEnded) {
          completedOvers += 1;
          currentOverBalls = 0;

          // _askForNewBowler();
        }

        if (completedOvers >= overs) {
          if (!inningsEnded) {
            inningsEnded = true;
            _endInnings();
          }
        }

        if (wickets >= players - 1) {
          if (!inningsEnded) {
            inningsEnded = true;
            _endInnings();
          }
        }
      });
    }
  }

  void _selectNewBatter() {
    // Check if there are still available batters
    if (batters.isNotEmpty) {
      setState(() {
        selectedBatter1 =
            batters.firstWhere((b) => b['status'] == 'out')['name'];
        batters.removeWhere((b) => b['name'] == selectedBatter1);
      });
    }
  }

  void _updateExtras(int extraRuns,
      {bool isWide = false, bool isNoBall = false}) {
    setState(() {
      extras += extraRuns;
      score += extraRuns;
      ballOutcomes.add(isWide
          ? -2
          : isNoBall
              ? -3
              : extraRuns);
      _updateBalls(countBall: false);
      // Update stats for the batter and bowler
      if (selectedBatter1 != null) {
        _updateBatterStats(selectedBatter1!, extraRuns);
      }
      if (selectedBowler != null) {
        _updateBowlerStats(selectedBowler!,
            isWicket: false); // No change for wickets
      }
    });

    // _saveMatchData();

  }

    void _updateScore(int runs) {
      setState(() {
        score += runs;
        ballOutcomes.add(runs);
        _updateBalls();

        // Update batsman stats
        if (selectedBatter1 != null) {
          _updateBatterStats(selectedBatter1!, runs);
        }

        _checkTargetReached();
      });
      // _saveMatchData();
    }

  void _updateWickets(String wicketType) {
    setState(() {
      wickets += 1;
      ballOutcomes.add(-1);
      _updateBalls();

      // Update batsman stats
      if (selectedBatter1 != null) {
        _updateBatterStats(selectedBatter1!, 0); // 0 runs for the out batsman
      }

      // Update bowler stats
      if (selectedBowler != null) {
        _updateBowlerStats(selectedBowler!, isWicket: true);
      }

      // Remove the out batsman and select the next one
      _selectNewBatter();

      // Check if only 1 player is left
      if (players - wickets == 1) {
        inningsEnded = true;
        _endInnings();
        return; // Stop further processing
      }

      // Check if wickets have reached the limit
      if (wickets >= players - 1) {
        inningsEnded = true;
        _endInnings();
      }
    });
  }

  void _addBatter(Map<String, dynamic> batter, String team) {
    setState(() {
      if (team == 'Team A') {
        batters.add(batter);
      } else {
        bowlers.add(batter);
      }
    });
  }

  void _checkTargetReached() {
    if (currentInning == 2) {
      if (score >= targetScore) {
        // Team B wins because they successfully chased the target
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.green,
            title:
                Text('Target Achieved!', style: TextStyle(color: Colors.white)),
            content: Text(
                'Congratulations! Team $teamB has chased the target of $targetScore successfully.',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                child: Text('Restart Match',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetMatch();
                },
              ),
              TextButton(
                child:
                    Text('Go to Home', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) =>
                        false, // This ensures all routes are removed, effectively going back to the Home screen
                  );
                },
              ),
            ],
          ),
        );
      } else if (balls >= overs * 6 || wickets >= 10) {
        // Match ended but Team A wins because Team B couldn't chase the target
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.redAccent,
            title: Text('Target Not Achieved',
                style: TextStyle(color: Colors.white)),
            content: Text(
                'Team $teamA wins! Team $teamB couldn’t chase the target of $targetScore.',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                child: Text('Restart Match',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetMatch();
                },
              ),
              TextButton(
                child:
                    Text('Go to Home', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      }
    }
  }

  void _endInnings() {
    String message;

    if (currentInning == 1) {
      message =
      'The first innings has ended with a score of $score/$wickets by team $teamA!';
    } else {
      message =
      'The second innings has ended with a score of $score/$wickets by team $teamB!';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Innings Ended', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (currentInning == 1) {
                _resetInnings(); // Prepare for next innings
                _endOver(score); // End the over properly
              } else {
                _showMatchEndDialog(); // End the match after second innings
              }
            },
            child: Text(
              currentInning == 1 ? 'Next Innings' : 'View Results',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  void _endOver(int runs) {
    // Update the score with the calculated over runs
    _updateScore(runs);

    // After updating the score, save the match data
    _saveMatchData();
  }

  bool isMatchOngoing = false;



  void _showMatchEndDialog() {
    String matchResult;

    // Determine the match result
    if (currentInning == 2) {
      if (score >= targetScore) {
        matchResult = '$teamB won by chasing the target of $targetScore!';
      } else {
        matchResult =
            '$teamA defended their target of $targetScore successfully!';
      }
    } else {
      matchResult = 'The match has ended.';
    }

    // Show the dialog with the match result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green,
        title: Text('Match Ended', style: TextStyle(color: Colors.white)),
        content: Text(
          '$matchResult\n\nFinal Score: $teamB $score/$wickets.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text('Restart Match', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
              _resetMatch();
            },
          ),
          TextButton(
            child: Text('Go to Home', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );

    // Update the match outcome in the database
    endMatch(teamA, teamB, matchResult);
  }

  void _resetInnings() {
    setState(() {
      targetScore = score + 1;
      score = 0;
      wickets = 0;
      balls = 0;
      completedOvers = 0;
      currentOverBalls = 0;
      extras = 0;
      ballOutcomes.clear();
      currentInning += 1;
      inningsEnded = false;
    });

    // Show dialog for selecting new batsmen from Team B and bowler from Team A
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddBattersAndBowlerDialog(
          context, teamB, teamA); // Swap the teams for second inning
    });
  }

  void _resetMatch() {
    setState(() {
      score = 0;
      wickets = 0;
      balls = 0;
      completedOvers = 0;
      currentOverBalls = 0;
      extras = 0;
      currentInning = 1;
      targetScore = 0;
      ballOutcomes.clear();
      inningsEnded = false;
    });
  }
  MatchModel? ongoingMatch;

// Function to load ongoing match
  void _loadOngoingMatch() async {
    final match = await DatabaseHelper().fetchOngoingMatch();
    setState(() {
      ongoingMatch = match;
    });

    if (ongoingMatch != null) {
      print("Ongoing Match Loaded: ");
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


  void _saveMatchData() {
    try {
      // Convert the batters and bowlers lists to JSON strings for storage
      String battersJson = jsonEncode(batters);
      String bowlersJson = jsonEncode(bowlers);

      String matchongoing = 'true';
      // Convert boolean or other types to supported types (e.g., int for boolean)
      final matchData = {
        'teamA': teamA,
        'teamB': teamB,
        'overs': overs,
        'players': players,
        'score': targetScore,
        'wickets': wickets,
        'extras': extras,
        'batters': battersJson,  // Store as a JSON string
        'bowlers': bowlersJson,  // Store as a JSON string
        'ismatchongoing': matchongoing,
      };

      // Print the match data to the console
      print("Saving Match Data: ");
      print("Team A: $teamA");
      print("Team B: $teamB");
      print("Overs: $overs");
      print("Players: $players");
      print("Target: $targetScore");
      print("Wickets: $wickets");
      print("Extras: $extras");
      print("Batters: $battersJson");
      print("Bowlers: $bowlersJson");
      print("MatchOnGoing: $matchongoing");

      // Save match data to the database
      DatabaseHelper().saveMatchData(matchData).then((id) {
        print("Match saved with id $id");

        // Fetch and print all saved matches
        DatabaseHelper().getAllMatches().then((matches) {
          print("All saved matches:");
          for (var match in matches) {
            print("Match ID: ${match['id']}");
            print("Team A: ${match['teamA']}");
            print("Team B: ${match['teamB']}");
            print("Overs: ${match['overs']}");
            print("Players: ${match['players']}");
            print("Target: ${match['score']}");
            print("Wickets: ${match['wickets']}");
            print("Extras: ${match['extras']}");
            print("Batters: ${match['batters']}");
            print("Bowlers: ${match['bowlers']}");
            print("Match On Going: ${match['ismatchongoing']}");
            print("-----------");
          }
        });
      });
    } catch (e) {
      print("Error saving match data: $e");
    }
  }



  // Future<void> _loadMatchData() async {
  //   try {
  //     List<Map<String, dynamic>> matchList = await DatabaseHelper().fetchMatchData();
  //     if (matchList.isNotEmpty) {
  //       var match = matchList.first;
  //       setState(() {
  //         // Load match data from the fetched list
  //         teamA = match['teamA'];
  //         teamB = match['teamB'];
  //         overs = match['overs'];
  //         players = match['players'];
  //         score = match['score'];
  //         wickets = match['wickets'];
  //         extras = match['extras'];
  //         batters = _parsePlayerStats(match['batters']);
  //         bowlers = _parsePlayerStats(match['bowlers']);
  //         isMatchOngoing = match['ismatchongoing']; // Load match ongoing status
  //       });
  //     }
  //   } catch (e) {
  //     print("Error loading match data: $e");
  //   }
  // }


  List<Map<String, dynamic>> _parsePlayerStats(String stats) {
    // Convert the stored player stats back from String to a list of maps if stored as JSON
    return List<Map<String, dynamic>>.from(json.decode(stats));
  }


  Future<void> _loadPlayers() async {
    try {
      // Check if database or team names are null
      if (widget.database == null) {
        throw Exception("Database is null");
      }

      if (widget.teamAPlayer == null || widget.teamBPlayer == null) {
        throw Exception("Team names are null");
      }

      // Fetch players from the database
      final teamAPlayersFromDb =
          await widget.database!.getPlayersByTeamName(widget.teamAPlayer!);
      final teamBPlayersFromDb =
          await widget.database!.getPlayersByTeamName(widget.teamBPlayer!);

      setState(() {
        teamAPlayers = teamAPlayersFromDb.map((player) => player.name).toList();
        teamBPlayers = teamBPlayersFromDb.map((player) => player.name).toList();
        isLoading = false;
      });

      print('Team A Players: $teamAPlayers');
      print('Team B Players: $teamBPlayers');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading players: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadMatchData();
    teamA = widget.data.teamA;
    teamB = widget.data.teamB;
    overs = widget.data.overs;
    players = widget.data.players;
    teamALogo = widget.data.teamALogo;
    teamBLogo = widget.data.teamBLogo;
    teamAPlayers = [];

    // Initialize empty player lists
    teamAPlayers = [];
    teamBPlayers = [];
    batters = widget.initialBatters ?? [];
    bowlers = widget.initialBowlers ?? [];

    // Call update function when match starts
    updateMatchInDatabase();

    if (remainingPlayers == 1) {
      _endInnings();
    }

    _loadPlayers().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddBattersAndBowlerDialog(context, teamA, teamB);
      });
    });
  }

  String get oversDisplay => '$completedOvers.$currentOverBalls';

  String get remainingOvers => '${overs - completedOvers}';

  int get remainingPlayers => players - wickets;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Scoreboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.green,
                    child: Text(
                      'Overs Left: $remainingOvers',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.green,
                    child: Text(
                      'PLayers Left: $remainingPlayers',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 30,
                              child: ClipOval(
                                child: Image.file(
                                  File(teamALogo),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(teamA,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ],
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 30,
                              child: ClipOval(
                                child: Image.file(
                                  File(teamBLogo),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(teamB,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),



            Column(
              children: [
                ScoreboardWidget(
                  score: score,
                  wickets: wickets,
                  extras: extras,
                  crr: currentrunrate,
                  target: currentInning > 1 ? targetScore : 0,
                  inning: currentInning,
                  onInningsEnd: () {
                    // Automatically end innings if wickets down to one less than the total allowed players
                    if (wickets >= players - 1) {
                      _endInnings();
                    }
                  },
                  teamA: teamA,
                  teamB: teamB,
                  teamALogo: teamALogo,
                  teamBLogo: teamBLogo,
                  totalPlayers: players,
                ),
                PlayerStatsWidget(
                  batters: batters,
                  bowlers: bowlers,
                ),
                OverBoardWidget(
                  overs: oversDisplay,
                  ballsCount: balls,
                  ballOutcomes: ballOutcomes,
                ),
                ScoreInputWidget(
                  remainOvers: remainingOvers,
                  onScoreUpdate: (int runs) => _updateScore(runs),
                  onWicketUpdate: (String wicketType) =>
                      _updateWickets(wicketType),
                  onExtrasUpdate: (int extraRuns,
                          {bool isWide = false, bool isNoBall = false}) =>
                      _updateExtras(extraRuns,
                          isWide: isWide, isNoBall: isNoBall),
                  updateBatterStats: (batterName, runs,
                      {addBall = true,
                      bool isBoundary = false,
                      bool isSix = false}) {
                    setState(() {
                      for (var batter in batters) {
                        if (batter['name'] == batterName) {
                          batter['r'] += runs; // Increment runs scored
                          if (addBall) {
                            batter['b'] += 1; // Increment balls faced
                          }
                          if (isBoundary) {
                            batter['4s'] =
                                (batter['4s'] ?? 0) + 1; // Increment boundaries
                          }
                          if (isSix) {
                            batter['6s'] =
                                (batter['6s'] ?? 0) + 1; // Increment sixes
                          }
                          batter['sr'] = (batter['b'] > 0)
                              ? (batter['r'] / batter['b']) * 100
                              : 0.0; // Calculate strike rate
                        }
                      }
                    });
                  },
                  updateBowlerStats: (bowlerName, runs,
                      {addBall = false,
                        bool isWicket = false,
                        bool isNoBall = false,
                        bool isWide = false,
                        bool isBoundary = false,
                        bool isSix = false}) {
                    if (bowlers != null) {
                      setState(() {
                        for (var bowler in bowlers) {
                          if (bowler['name'] == bowlerName) {
                            // Handle runs
                            if (isBoundary) {
                              bowler['r'] += 4; // Add 4 runs for boundary
                            } else if (isSix) {
                              bowler['r'] += 6; // Add 6 runs for six
                            } else {
                              bowler['r'] += runs; // Regular runs
                            }
                            if (addBall && !isWide && !isNoBall) {
                              bowler['balls'] = (bowler['balls'] ?? 0) + 1;

                              // Calculate overs in proper cricket format
                              int totalBalls = bowler['balls'] ?? 0;
                              int fullOvers = totalBalls ~/ 6; // Full overs
                              int remainingBalls = totalBalls % 6; // Remaining balls
                              bowler['o'] = fullOvers + (remainingBalls / 10.0); // Store overs in decimal format
                            }
                            // // Handle wides and no-balls
                            // if (isWide) {
                            //   bowler['wide'] = (bowler['wide'] ?? 0) + 1; // Increment wides
                            //   bowler['r'] += 1; // Add extra run for wide
                            //   continue; // No ball count increment for wides
                            // }
                            // if (isNoBall) {
                            //   bowler['noBalls'] = (bowler['noBalls'] ?? 0) + 1; // Increment no-balls
                            //   bowler['r'] += 1; // Add extra run for no-ball
                            //   continue; // No ball count increment for no-balls
                            // }

                            // // Increment ball count only for valid deliveries
                            // if (addBall) {
                            //   bowler['balls'] = (bowler['balls'] ?? 0) + 1;
                            //
                            //   // Calculate overs in proper cricket format
                            //   int totalBalls = bowler['balls'] ?? 0;
                            //   int fullOvers = totalBalls ~/ 6; // Full overs
                            //   int remainingBalls = totalBalls % 6; // Remaining balls in the current over
                            //   bowler['o'] = fullOvers + remainingBalls / 6.0; // Store overs as a double
                            // }

                            // Handle Wicket
                            if (isWicket) {
                              bowler['w'] = (bowler['w'] ?? 0) + 1; // Increment wickets
                            }

                            // Calculate Economy Rate (runs per over)
                            int totalBalls = bowler['balls'] ?? 0;
                            if (totalBalls > 0) {
                              bowler['econ'] = bowler['r'] / (totalBalls / 6.0); // Runs per over
                            } else {
                              bowler['econ'] = 0.0; // Prevent division by zero
                            }
                          }
                        }
                      });
                    }
                  },

                  batters: batters,
                  bowlers: bowlers,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
