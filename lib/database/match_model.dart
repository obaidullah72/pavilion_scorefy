import 'package:sqflite/sqflite.dart';

class MatchModel {
  final int id;
  final String teamA;
  final String teamB;
  final int overs;
  final int players;
  final int score;
  final int wickets;
  final int extras;
  final String batters;
  final String bowlers;
  final String isMatchOngoing;

  MatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.overs,
    required this.players,
    required this.score,
    required this.wickets,
    required this.extras,
    required this.batters,
    required this.bowlers,
    required this.isMatchOngoing,
  });

  // Convert Map to MatchModel object
  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'],
      teamA: map['teamA'],
      teamB: map['teamB'],
      overs: map['overs'],
      players: map['players'],
      score: map['score'],
      wickets: map['wickets'],
      extras: map['extras'],
      batters: map['batters'],
      bowlers: map['bowlers'],
      isMatchOngoing: map['ismatchongoing'],
    );
  }

  // Convert MatchModel object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamA': teamA,
      'teamB': teamB,
      'overs': overs,
      'players': players,
      'score': score,
      'wickets': wickets,
      'extras': extras,
      'batters': batters,
      'bowlers': bowlers,
      'ismatchongoing': isMatchOngoing,
    };
  }
}

class PlayerStats {
  String name;
  int runs;
  int balls;
  int fours;
  int sixes;
  double strikeRate;

  PlayerStats({
    required this.name,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'strikeRate': strikeRate,
    };
  }

  static PlayerStats fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      name: map['name'],
      runs: map['runs'],
      balls: map['balls'],
      fours: map['fours'],
      sixes: map['sixes'],
      strikeRate: map['strikeRate'],
    );
  }
}
