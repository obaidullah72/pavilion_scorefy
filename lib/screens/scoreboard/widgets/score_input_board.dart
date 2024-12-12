import 'package:flutter/material.dart';

class ScoreInputWidget extends StatefulWidget {

  final String remainOvers;
  final Function(int) onScoreUpdate;
  final Function(String) onWicketUpdate;
  final Function(int, {bool isWide, bool isNoBall}) onExtrasUpdate;
  final Function(String, int, {bool addBall, bool isBoundary, bool isSix})
      updateBatterStats;
  final Function(String, int, {bool addBall, bool isWicket, bool isWide, bool isNoBall, bool isBoundary, bool isSix})
      updateBowlerStats;
  final List<Map<String, dynamic>> batters;
  final List<Map<String, dynamic>> bowlers; // Add a list of bowlers

  ScoreInputWidget({
    required this.onScoreUpdate,
    required this.onWicketUpdate,
    required this.onExtrasUpdate,
    required this.updateBatterStats,
    required this.updateBowlerStats,
    required this.batters,
    required this.bowlers,
    required this.remainOvers,
  });

  @override
  _ScoreInputWidgetState createState() => _ScoreInputWidgetState();
}

class _ScoreInputWidgetState extends State<ScoreInputWidget> {
  int strikerIndex = 0; // Index for the striker
  int nonStrikerIndex = 1; // Index for the non-striker
  int currentBowlerIndex = 0;
  final List<String> wicketTypes = ["Caught Out", "LBW", "Run Out", "Bowled"];
  int ballsCounted = 0;
  int currentOverBalls = 0;
  final int ballsPerOver = 6;
  late int totalOvers; // Total overs in the innings


  @override
  void initState() {
    super.initState();
    totalOvers = int.tryParse(widget.remainOvers) ?? 0; // Parse total overs
  }

  void _addBallToOver() {
    setState(() {
      currentOverBalls++;
      ballsCounted++;

      // Update bowler stats for a valid ball
      final bowlerName = widget.bowlers[currentBowlerIndex]['name'];
      widget.updateBowlerStats(
        bowlerName,
        0, // No runs directly from the ball count
        addBall: false,
      );

      if (currentOverBalls == ballsPerOver) {
        _endOver();
      }

      if (_getRemainingBalls() <= 0) {
        _showInningsEndDialog(context);
      }
    });
  }

  // Function to handle the end of an over
  void _endOver() {
    setState(() {
      currentOverBalls = 0; // Reset the over ball count
      _showEndOverDialog(context);
    });
  }

  int _getRemainingBalls() {
    int totalBalls = totalOvers * ballsPerOver;
    return totalBalls - ballsCounted;
  }

  String _getRemainingOvers() {
    int remainingBalls = _getRemainingBalls();
    int overs = remainingBalls ~/ ballsPerOver; // Full overs left
    int balls = remainingBalls % ballsPerOver; // Remaining balls
    return "$overs.$balls";
  }
  void _showEndOverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.green,
          title: const Text(
            'End of Over',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'The over has ended. Select the next bowler.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Logic to select a new bowler (if required)
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Remaining Overs: ${_getRemainingOvers()}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Text(
        //   "Balls Bowled: $ballsCounted",
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        // ),
        // Text(
        //   "Current Over: $currentOverBalls.$ballsPerOver",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // Text(
        //   "Striker: ${widget.batters[strikerIndex]['name'] ?? 'No Striker'}",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // Text(
        //   "Non-Striker: ${widget.batters[nonStrikerIndex]['name'] ?? 'No Non-Striker'}",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // Text(
        //   "Bowler: ${widget.bowlers[currentBowlerIndex]['name'] ?? 'No Bowler'}",
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 3.0,
          crossAxisSpacing: 3.0,
          children: [
            _buildGridButton(context, "DOT", Colors.white, Colors.black, 0),
            _buildGridButton(context, "1", Colors.white, Colors.black, 1),
            _buildGridButton(context, "2", Colors.white, Colors.black, 2),
            _buildGridButton(context, "3", Colors.white, Colors.black, 3),
            _buildGridButton(context, "4", Colors.blueAccent, Colors.white, 4,
                isBoundary: true),
            _buildGridButton(context, "5", Colors.white, Colors.black, 5),
            _buildGridButton(context, "6", Colors.deepOrange, Colors.white, 6,
                isSix: true),
            _buildGridButton(context, "NO BALL", Colors.green, Colors.white, 1,
                isExtra: true, isNoBall: true),
            _buildGridButton(context, "WIDE", Colors.green, Colors.white, 1,
                isExtra: true, isWide: true),
            _buildGridButton(context, "WICKET", Colors.red, Colors.white, null,
                isWicket: true),
          ],
        ),
      ],
    );
  }

  Widget _buildGridButton(BuildContext context, String text, Color bgColor,
      Color textColor, int? runs,
      {bool isWicket = false,
        bool isExtra = false,
        bool isWide = false,
        bool isNoBall = false,
        bool isBoundary = false,
        bool isSix = false}) {
    return GestureDetector(
      onTap: () {
        final bowlerName = widget.bowlers[currentBowlerIndex]['name'];

        if (isWicket) {
          widget.updateBowlerStats(
            bowlerName, // Bowler name
            0, // Runs scored for wicket event (no runs)
            isWicket: true, // Mark it as a wicket
          );
          _showWicketDialog(context); // Show wicket dialog
          _handleWicket();
        } else if (isExtra) {
          if (isWide) {
            // Update the bowler stats for wide (1 run added)
            widget.updateBowlerStats(bowlerName, 1, isWide: true);
            widget.onExtrasUpdate(1, isWide: true); // Handle extras for wide
          } else if (isNoBall) {
            widget.updateBowlerStats(bowlerName, 1, isNoBall: true);
            widget.onExtrasUpdate(1, isNoBall: true); // Handle extras for no-ball
          }
        } else if (runs != null) {
          // Handle normal run updates
          widget.onScoreUpdate(runs);
          widget.updateBatterStats(
            widget.batters[strikerIndex]['name'],
            runs,
            addBall: true,
            isBoundary: isBoundary,
            isSix: isSix,
          );
          widget.updateBowlerStats(
            addBall: true,
              bowlerName,
              runs, // Runs scored
              isWicket: isWicket, // Is it a wicket?
              isNoBall: isNoBall, // Is it a no-ball?
              isBoundary: isBoundary, // Is it a boundary?
              isSix: isSix // Is it a six?
          );

          if (runs % 2 != 0) {
            _swapStrikers(); // Swap strikers for odd runs
          }
        }
        // Add ball for valid deliveries (not wide or no-ball)
        if (!isExtra || (!isWide && !isNoBall)) {
          _addBallToOver();
        }

        // Track the number of balls bowled in the over
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.greenAccent, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _handleWicket() {
    widget.onWicketUpdate(wicketTypes[0]);
    setState(() {
      widget.batters.removeAt(strikerIndex);
      if (widget.batters.length < 3) {
        _showInningsEndDialog(context);
      } else {
        strikerIndex = strikerIndex % widget.batters.length;
        _showNewBatterDialog(context);
      }
    });
  }

  void _swapStrikers() {
    setState(() {
      int temp = strikerIndex;
      strikerIndex = nonStrikerIndex;
      nonStrikerIndex = temp;
    });
  }

  void _showWicketDialog(BuildContext context) {
    String selectedWicketType = wicketTypes[0];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.green[50],
          title: Text(
            "Select Wicket Type",
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: DropdownButton<String>(
                  value: selectedWicketType,
                  isExpanded: true,
                  dropdownColor: Colors.green[50],
                  underline: Container(),
                  style: TextStyle(color: Colors.green[900], fontSize: 16),
                  items: wicketTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWicketType = newValue!;
                    });
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showNewBatterDialog(context);
                // widget.onWicketUpdate(selectedWicketType);

                // Set next batter as striker
                // setState(() {
                //   if (currentBatterIndex + 1 < batters.length) {
                //     currentBatterIndex += 1;
                //   }
                // });
              },
              child: Text(
                "Dismiss",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  void _showNewBatterDialog(BuildContext context) {
    String? selectedBatter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.green[50],
          title: Text(
            "Select New Batter",
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: DropdownButton<String>(
                  value: selectedBatter,
                  isExpanded: true,
                  hint: Text("Select batter"),
                  dropdownColor: Colors.green[50],
                  underline: Container(),
                  style: TextStyle(color: Colors.green[900], fontSize: 16),
                  items: widget.batters.map((batter) {
                    return DropdownMenuItem<String>(
                      value: batter['name'],
                      child: Text(batter['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBatter = newValue;
                    });
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedBatter != null) {
                  setState(() {
                    // Set the selected batter as the new striker
                    final newBatter = widget.batters.firstWhere(
                            (batter) => batter['name'] == selectedBatter);
                    widget.batters.remove(newBatter);
                    widget.batters.insert(
                        strikerIndex, newBatter); // Insert at striker position
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text(
                "Confirm",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInningsEndDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.red[50],
          title: Text(
            "Innings Ended",
            style: TextStyle(
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "All players are out, and the innings has ended.",
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Additional logic for ending innings (e.g., navigating to the next screen)
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
