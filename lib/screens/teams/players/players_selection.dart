import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pavilion_scorefy/screens/teams/players/player_search_list.dart';
import '../../../database/db_helper.dart';
import '../../../database/players_model.dart';
import '../../../database/team_model.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final String teamName;
  final int? teamid;
  final String teamLogoUrl;
  final Function(List<Player>) onPlayersUpdated;

  PlayerSelectionScreen({
    required this.teamName,
    required this.teamLogoUrl,
    this.teamid,
    required this.onPlayersUpdated,
  });

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  String? teamLogoUrl;
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    if (widget.teamid != null) {
      _fetchTeamLogo();
      _fetchPlayers(); // Fetch existing players if available
    }
  }

  void _fetchPlayers() async {
    final dbHelper = DatabaseHelper();
    if (widget.teamid != null) {
      List<Player> fetchedPlayers = await dbHelper.getPlayersByTeamId(widget.teamid!);
      setState(() {
        players = fetchedPlayers;
      });
    }
  }

  void _fetchTeamLogo() async {
    final dbHelper = DatabaseHelper();
    Team? team = await dbHelper.getTeam(widget.teamid!);
    setState(() {
      teamLogoUrl = team?.logo;
    });
  }

  void _updatePlayers() {
    widget.onPlayersUpdated(players);
    Navigator.pop(context, players.length);
  }

  void _addPlayerToTeam(Player player) async {
    final dbHelper = DatabaseHelper();

    try {
      bool playerExists = await dbHelper.isPlayerInTeam(widget.teamid!, player.id!);
      if (playerExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.name} is already in the team!'), duration: Duration(milliseconds: 100,),),
        );
        return;
      }

      player.isAvailable = false;
      await dbHelper.updatePlayerAvailability(player);
      await dbHelper.addPlayerToTeam(widget.teamid!, [player.id!]);

      setState(() {
        players.add(player);
      });

      _updatePlayers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${player.name} is either unavailable or already in the team.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(widget.teamName),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundImage: teamLogoUrl != null
                ? FileImage(File(teamLogoUrl!))
                : AssetImage('assets/team.jpg') as ImageProvider,
          ),
          SizedBox(height: 16),
          Text(
            "Select Players",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: PlayerSearchList(
              teamid: widget.teamid,
              onPlayerSelected: (player) {
                _addPlayerToTeam(player);
              },
            ),
          ),
        ],
      ),
    );
  }
}
