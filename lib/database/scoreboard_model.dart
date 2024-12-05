  import 'package:pavilion_scorefy/database/players_model.dart';

  class ScoreboardScreenData {
    final String teamA;
    final String teamB;
    final int overs;
    final int players;
    final String teamALogo;
    final String teamBLogo;
    final List<Player> playersTeamA;
    final List<Player> playersTeamB;
    final String? selectedBatter1; // Add these
    final String? selectedBatter2;
    final String? selectedBowler;

    ScoreboardScreenData({
      required this.teamA,
      required this.teamB,
      required this.overs,
      required this.players,
      required this.teamALogo,
      required this.teamBLogo,
      required this.playersTeamA,
      required this.playersTeamB,
      this.selectedBatter1,
      this.selectedBatter2,
      this.selectedBowler,
    });
  }
