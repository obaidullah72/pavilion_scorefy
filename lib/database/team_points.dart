class TeamPoint {
  final int id; // Primary key
  final int teamId; // Foreign key referencing the team
  final int matches; // Number of matches played
  final int won; // Number of matches won
  final int lost; // Number of matches lost
  final int tied; // Number of matches tied
  final double winPercentage; // Win percentage

  TeamPoint({
    required this.id,
    required this.teamId,
    required this.matches,
    required this.won,
    required this.lost,
    required this.tied,
    required this.winPercentage,
  });

  // Convert a Map to a TeamPoint object (used when fetching data from the database)
  factory TeamPoint.fromMap(Map<String, dynamic> map) {
    return TeamPoint(
      id: map['id'],
      teamId: map['team_id'],
      matches: map['matches'],
      won: map['won'],
      lost: map['lost'],
      tied: map['tied'],
      winPercentage: map['winPercentage'],
    );
  }

  // Convert a TeamPoint object to a Map (used when inserting/updating data in the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team_id': teamId,
      'matches': matches,
      'won': won,
      'lost': lost,
      'tied': tied,
      'winPercentage': winPercentage,
    };
  }
}
