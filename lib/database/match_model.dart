import 'package:sqflite/sqflite.dart';

class MatchModel {
  int id;
  String teamA;
  String teamB;
  int overs;
  int currentOver;
  bool isMatchOngoing;

  MatchModel({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.overs,
    required this.currentOver,
    required this.isMatchOngoing,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamA': teamA,
      'teamB': teamB,
      'overs': overs,
      'currentOver': currentOver,
      'isMatchOngoing': isMatchOngoing ? 1 : 0,
    };
  }

  static MatchModel fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'],
      teamA: map['teamA'],
      teamB: map['teamB'],
      overs: map['overs'],
      currentOver: map['currentOver'],
      isMatchOngoing: map['isMatchOngoing'] == 1,
    );
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
