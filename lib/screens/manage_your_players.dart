import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/database/players_model.dart';
import '../database/db_helper.dart';

class ManagePlayersScreen extends StatefulWidget {
  final int? teamid;

  ManagePlayersScreen({this.teamid});

  @override
  _ManagePlayersScreenState createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  List<TextEditingController> playerControllers = [];
  List<Player> players = [];

  // Add a new text field when "+" is clicked
  void addPlayerField() {
    setState(() {
      playerControllers.add(TextEditingController());
    });
  }

  // Save all players to the database and update the player list
// Save all players to the database and update the player list
  void savePlayers() async {
    for (int i = 0; i < playerControllers.length; i++) {
      String playerName = playerControllers[i].text;

      if (playerName.isNotEmpty) {
        // Check if the player already exists in the database by name
        Player? existingPlayer =
            await DatabaseHelper.instance.getPlayerByName(playerName);

        if (existingPlayer == null) {
          // Player does not exist, so insert them into the database
          Player newPlayer =
              Player(name: playerName, isAvailable: true);
          await DatabaseHelper.instance.insertPlayer(newPlayer);
          print("Inserted player: $playerName");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Inserted player: $playerName",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 300),
            ),
          );
        } else {
          // Player already exists, skip inserting
          print("Player $playerName already exists in the database.");
        }
      }
    }

    loadPlayers(); // Refresh the player list after insertion
  }

  // Fetch players from the database
  void loadPlayers() async {
    List<Player> playerList = await DatabaseHelper.instance.getAllPlayers()
        .then((data) => data.map((player) => Player.fromMap(player)).toList());
    print("Players loaded: $playerList"); // Debugging line
    setState(() {
      players = playerList;
      playerControllers = players
          .map((player) => TextEditingController(text: player.name))
          .toList();
      print("Players List: ${players.length}");
    });
  }

  // Function to remove a player from the list and database
  void removePlayer(int index) async {
    if (playerControllers[index].text.isNotEmpty) {
      String playerName = playerControllers[index].text;

      // Find the player by name
      Player? playerToDelete = players.firstWhere(
        (player) => player.name == playerName,
        orElse: () => null!, // Returning null explicitly
      );

      if (playerToDelete != null && playerToDelete.id != null) {
        await DatabaseHelper.instance.deletePlayer(playerToDelete.id!);
        setState(() {
          playerControllers.removeAt(index); // Remove from the list
          players.removeAt(index); // Remove from the players list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Deleted player: $playerName",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(milliseconds: 300),
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch players from the database when the screen loads
    loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text('Manage Your Players'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addPlayerField, // Add player field when "+" is clicked
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Players input fields
            Expanded(
              child: ListView.builder(
                itemCount: playerControllers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: TextField(
                      controller: playerControllers[index],
                      decoration:
                          InputDecoration(hintText: 'Enter player name'),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => removePlayer(index),
                    ),
                  );
                },
              ),
            ),

            // Save button
            ElevatedButton(
              onPressed: savePlayers,
              child: Text('SAVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
