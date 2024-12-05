import 'package:flutter/material.dart';

class OverBoardWidget extends StatelessWidget {
  final List<int> ballOutcomes;
  final String overs;
  final int ballsCount;

  OverBoardWidget({
    required this.overs,
    required this.ballsCount,
    required this.ballOutcomes,
  });

  @override
  Widget build(BuildContext context) {
    // Filter only actual balls and organize in chunks of 6 for overs
    List<List<int>> overChunks = [];
    List<int> currentOver = [];
    int actualBalls = 0;

    for (int outcome in ballOutcomes) {
      if (outcome != -2 && outcome != -3) { // Ignore WD and NB for count
        actualBalls++;
      }
      currentOver.add(outcome);

      if (actualBalls == 6) {
        overChunks.add(List.from(currentOver));
        currentOver.clear();
        actualBalls = 0;
      }
    }

    if (currentOver.isNotEmpty) {
      // Pad the last over with zeroes if it has less than 6 balls
      while (currentOver.length < 6) {
        currentOver.add(0);
      }
      overChunks.add(currentOver);
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Overs: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $overs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Number of Balls: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $ballsCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(overChunks.length, (i) {
              return Row(
                children: [
                  Row(
                    children: overChunks[i].map((outcome) {
                      String outcomeText;
                      Color boxColor;

                      if (outcome == 6) {
                        outcomeText = '6';
                        boxColor = Colors.deepPurple;
                      } else if (outcome == 4) {
                        outcomeText = '4';
                        boxColor = Colors.deepOrange;
                      } else if (outcome == -1) {
                        outcomeText = 'W';
                        boxColor = Colors.red;
                      } else if (outcome == -2) {
                        outcomeText = 'WD';
                        boxColor = Colors.purple;
                      } else if (outcome == -3) {
                        outcomeText = 'NB';
                        boxColor = Colors.red;
                      } else if (outcome == 0) {
                        outcomeText = '.';
                        boxColor = Colors.blueGrey;
                      }
                      else {
                        outcomeText = '$outcome';
                        boxColor = Colors.blueGrey;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: boxColor,
                            shape: BoxShape.rectangle,
                          ),
                          child: Center(
                            child: Text(
                              outcomeText,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (i < overChunks.length - 1)
                    VerticalDivider(
                      color: Colors.black,
                      width: 10,
                      thickness: 1,
                    ), // Divider between overs
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
