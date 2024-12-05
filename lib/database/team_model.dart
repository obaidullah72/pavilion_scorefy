import 'package:pavilion_scorefy/database/players_model.dart';

class Team {
  int? id;
  String teamName;
  String logo;
  List<Player>? players; // Change this to List<PlayersModel>

  Team({
    this.id,
    required this.teamName,
    required this.logo,
    this.players,
  });

  // Convert a map into a Team object
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      teamName: map['teamName'],
      logo: map['logo'],
      players: [], // Initialize with an empty list or null
    );
  }

  // Convert a Team object into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'logo': logo,
    };
  }
}
