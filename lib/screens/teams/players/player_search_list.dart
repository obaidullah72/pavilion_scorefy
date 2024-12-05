import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';
import '../../../database/players_model.dart';

class PlayerSearchList extends StatelessWidget {
  final int? teamid;
  final Function(Player) onPlayerSelected;

  PlayerSearchList({this.teamid, required this.onPlayerSelected});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Player>>(
      future: _fetchAvailablePlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No players available'));
        }

        List<Player> players = snapshot.data!;

        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            Player player = players[index];

            return ListTile(
              title: Text(player.name!),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  if (teamid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No team selected')),
                    );
                    return;
                  }

                  if (player.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid player')),
                    );
                    return;
                  }

                  final dbHelper = DatabaseHelper.instance;

                  try {
                    // bool playerExists = await dbHelper.isPlayerInTeam(teamid!, player.id!);
                    // if (playerExists) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text('${player.name} is already in the team!')),
                    //   );
                    //   return;
                    // }

                    player.isAvailable = false;
                    await dbHelper.updatePlayerAvailability(player);
                    await dbHelper.addPlayerToTeam(teamid!, [player.id!]);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${player.name} added to team'), duration: Duration(seconds: 1)),
                    );

                    onPlayerSelected(player);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding player to team: $e')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Player>> _fetchAvailablePlayers() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getAvailablePlayers();
  }
}
