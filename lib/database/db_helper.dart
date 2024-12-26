import 'dart:convert';

import 'package:path/path.dart';
import 'package:pavilion_scorefy/database/players_model.dart';
import 'package:pavilion_scorefy/database/team_model.dart';
import 'package:pavilion_scorefy/database/team_points.dart';
import 'package:sqflite/sqflite.dart';

import 'match_model.dart';

class DatabaseHelper {
  static final _databaseName = "pavilion_scorefy.db";
  static final _databaseVersion = 1;

  static final tableTeams = 'teams';
  static final tablePlayers = 'players';
  static final tableTeamPlayers = 'team_players';

  static final columnId = 'id';
  static final columnTeamName = 'teamName';
  static final columnLogo = 'logo';
  static final columnPlayerName = 'name';
  static final columnIsAvailable = 'isAvailable';
  static final columnTeamId = 'team_id';
  static final columnPlayerId = 'player_id'; // Player ID in the junction table

  // Singleton pattern
  DatabaseHelper.internal();

  // factory DatabaseHelper() => _instance;

  // static final DatabaseHelper instance = DatabaseHelper.internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor
  factory DatabaseHelper() => _instance;

  // static Database? _database;

  // Getter for database instance, initializes it if null
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Database initialization and path setup
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    print("Database path: $path");

    // Uncomment this line temporarily to force delete the old database (for testing purposes)
    // await deleteDatabase(path); // Deletes the database for a fresh start

    // Open the database and create tables if they don't exist
    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  // Function to create tables in the database
  Future<void> _onCreate(Database db, int version) async {
    print("Creating tables...");

    // Create players table with a foreign key to teams table
    await db.execute('''
    CREATE TABLE players (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      isAvailable INTEGER,
      mat INTEGER,  -- Adding mat column
      no INTEGER,
      runs INTEGER,
      avg REAL,
      sr REAL,
      wkts INTEGER,
      bbm TEXT,
      eco REAL,
      bowlingavg REAL
    )
  ''');

    await db.execute('''
  CREATE TABLE matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    teamA TEXT,
    teamB TEXT,
    overs INTEGER,
    players INTEGER,
    score INTEGER,
    wickets INTEGER,
    extras INTEGER,
    batters TEXT,
    bowlers TEXT,
    ismatchongoing INTEGER
  )
''');

    await db.execute('''
          CREATE TABLE player_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            matchId INTEGER,
            name TEXT,
            runs INTEGER,
            balls INTEGER,
            fours INTEGER,
            sixes INTEGER,
            strikeRate REAL,
            FOREIGN KEY (matchId) REFERENCES matches(id)
          )
        ''');

    // Create teams table
    await db.execute('''
      CREATE TABLE $tableTeams (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTeamName TEXT NOT NULL,
        $columnLogo TEXT NOT NULL
      );
    ''');

    // Create team_points table (merging team performance data)
    await db.execute('''
      CREATE TABLE team_points(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id INTEGER,
        matches INTEGER,
        won INTEGER,
        lost INTEGER,
        tied INTEGER,
        winPercentage REAL,
        FOREIGN KEY (team_id) REFERENCES teams(id)
      )
    ''');

    // Create the team_players junction table
    await db.execute('''
      CREATE TABLE $tableTeamPlayers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTeamId INTEGER,
        $columnPlayerId INTEGER,
        FOREIGN KEY ($columnTeamId) REFERENCES $tableTeams($columnId),
        FOREIGN KEY ($columnPlayerId) REFERENCES $tablePlayers($columnId)
      );
    ''');

    print("Tables created successfully!");
  }

  Future<void> insertMatch(MatchModel match) async {
    final db = await database;
    await db.insert('matches', match.toMap());
  }

  Future<MatchModel?> fetchOngoingMatch() async {
    final db = await database;
    final maps = await db.query(
      'matches',
      where: 'isMatchOngoing = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return MatchModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateMatch(MatchModel match) async {
    final db = await database;
    await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

// Save match data into the database
  Future<int> saveMatchData(Map<String, dynamic> matchData) async {
    Database db = await database;

    // Check if match is ongoing or not, and update accordingly
    bool isMatchOngoing = true; // Match is ongoing if currentInning is 1 or less

    // Add or update the isMatchOngoing field in match data
    matchData['ismatchongoing'] = isMatchOngoing;

    return await db.insert('matches', matchData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Fetch match data from the database
  Future<List<Map<String, dynamic>>> fetchMatchData() async {
    Database db = await database;
    return await db.query('matches');
  }

  List<Map<String, dynamic>> _parsePlayerStats(String stats) {
    return List<Map<String, dynamic>>.from(json.decode(stats));
  }

  // Fetch match by id
  Future<Map<String, dynamic>?> fetchMatchById(int id) async {
    Database db = await database;
    var result =
        await db.query('matches', where: '$columnId = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Map<String, dynamic>.from(
          result.first); // Ensure casting to Map<String, dynamic>
    } else {
      return null; // Return null if no match is found
    }
  }

  // Future<List<Map<String, dynamic>>> fetchOngoingMatch() async {
  //   final db = await database;
  //   return await db.query('match_data', where: "match_status = ?", whereArgs: ["ongoing"]);
  // }

  Future<int> updateMatchData(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
    return await db
        .update('match_data', updatedData, where: "id = ?", whereArgs: [id]);
  }

  // Inserting a player with stats
  Future<int> insertPlayer(Player player) async {
    Database db = await DatabaseHelper().database;

    // Use player properties to insert them into the table
    return await db.insert('players', {
      'name': player.name,
      'isAvailable': player.isAvailable! ? 1 : 0,
      'mat': player.mat, // Assuming you have these fields in your Player model
      'no': player.no,
      'runs': player.runs,
      'avg': player.avg,
      'sr': player.sr,
      'wkts': player.wkts,
      'bbm': player.bbm,
      'eco': player.eco,
      'bowlingavg': player.bowlingavg,
    });
  }

  // Insert a new team into the database
  Future<int> insertTeam(Team team) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(tableTeams, team.toMap());
  }

  // Insert a new team-player relationship into the junction table
  Future<int> insertTeamPlayer(int teamId, int playerId) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(tableTeamPlayers, {
      columnTeamId: teamId,
      columnPlayerId: playerId,
    });
  }

  // Insert team performance data into team_points table
  Future<int> insertTeamPoints(int teamId, int matches, int won, int lost,
      int tied, double winPercentage) async {
    Database db = await DatabaseHelper().database;
    return await db.insert('team_points', {
      'team_id': teamId,
      'matches': matches,
      'won': won,
      'lost': lost,
      'tied': tied,
      'winPercentage': winPercentage
    });
  }

  Future<bool> isPlayerInTeam(int teamId, int playerId) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(
      'team_players',
      where: 'team_id = ? AND player_id = ?',
      whereArgs: [teamId, playerId],
    );
    return result.isNotEmpty;
  }

  Future<int> updatePlayerAvailability(Player player) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'players',
      {'isAvailable': player.isAvailable! ? 1 : 0},
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<void> updateTeamPoints(int teamId, bool isWin, bool isTie) async {
    final db = await DatabaseHelper().database;

    // Retrieve current stats for the team
    var result = await db
        .query('team_points', where: 'team_id = ?', whereArgs: [teamId]);
    if (result.isNotEmpty) {
      // If team data exists, update it
      var currentStats = result.first;

      // Cast values to int and use null-aware operator (??)
      int matches = ((currentStats['matches'] as int?) ?? 0) + 1;
      int won = ((currentStats['won'] as int?) ?? 0) + (isWin ? 1 : 0);
      int lost = ((currentStats['lost'] as int?) ?? 0) +
          (isWin
              ? 0
              : !isTie
                  ? 1
                  : 0);
      int tied = ((currentStats['tied'] as int?) ?? 0) + (isTie ? 1 : 0);

      double winPercentage = (matches > 0) ? (won / matches) * 100 : 0.0;

      await db.update(
          'team_points',
          {
            'matches': matches,
            'won': won,
            'lost': lost,
            'tied': tied,
            'winPercentage': winPercentage,
          },
          where: 'team_id = ?',
          whereArgs: [teamId]);
    } else {
      // If no data exists for the team, insert new record
      await db.insert('team_points', {
        'team_id': teamId,
        'matches': 1,
        'won': isWin ? 1 : 0,
        'lost': isWin
            ? 0
            : !isTie
                ? 1
                : 0,
        'tied': isTie ? 1 : 0,
        'winPercentage': isWin ? 100 : 0,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    final db = await database; // Access your SQLite database
    return await db
        .query('players'); // Replace 'players' with your actual table name
  }

  // Update match outcome in the database
  Future<void> updateMatchOutcome(
      String teamA, String teamB, String outcome) async {
    // final db = await database;

    // Fetch team IDs for the given team names
    final teamAData = await getTeamByName(teamA);
    final teamBData = await getTeamByName(teamB);

    if (teamAData == null || teamBData == null) {
      print("One or both teams not found in the database.");
      return;
    }

    final teamAId = teamAData.id!;
    final teamBId = teamBData.id!;

    // Update team_points for both teams based on outcome
    switch (outcome) {
      case 'TeamA Wins':
        await _incrementTeamStats(teamAId, won: 1);
        await _incrementTeamStats(teamBId, lost: 1);
        break;

      case 'TeamB Wins':
        await _incrementTeamStats(teamBId, won: 1);
        await _incrementTeamStats(teamAId, lost: 1);
        break;

      case 'Tie':
        await _incrementTeamStats(teamAId, tied: 1);
        await _incrementTeamStats(teamBId, tied: 1);
        break;

      default:
        print("Invalid outcome.");
        return;
    }
  }

  // Fetch the team by name
  Future<Team> getTeamByName(String teamName) async {
    var db = await DatabaseHelper().database;
    var result = await db.query(
      'teams',
      where: 'name = ?',
      whereArgs: [teamName],
    );
    return Team.fromMap(result.first);
  }

// Fetch team points by team ID
  Future<TeamPoint> getTeamPointsByTeamId(int teamId) async {
    var db = await DatabaseHelper().database;
    var result = await db.query(
      'team_points',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    return TeamPoint.fromMap(result.first);
  }

  Future<List<Map<String, dynamic>>> getAllTeamsWithPerformance() async {
    final db = await DatabaseHelper()
        .database; // Assuming you have a database instance

    // Sample SQL query to join teams and performance data
    String query = '''
      SELECT teams.name AS teamName, 
             tp.matches, tp.won, tp.lost, tp.tied, tp.winPercentage
      FROM teams
      LEFT JOIN team_points tp ON teams.id = tp.team_id
    ''';

    var result = await db.rawQuery(query);
    return result;
  }

// Update team points in the database
//   Future<void> updateTeamPoints(int teamId, int matches, int won, int lost, int tied, double winPercentage) async {
//     var db = await DatabaseHelper().database;
//     await db.update(
//       'team_points',
//       {
//         'matches': matches,
//         'won': won,
//         'lost': lost,
//         'tied': tied,
//         'winPercentage': winPercentage,
//       },
//       where: 'team_id = ?',
//       whereArgs: [teamId],
//     );
//   }

// Increment match stats for a team
  Future<void> _incrementTeamStats(int teamId,
      {int matches = 1, int won = 0, int lost = 0, int tied = 0}) async {
    final db = await database;

    // Fetch existing stats for the team
    final stats = await db.query(
      'team_points',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );

    if (stats.isNotEmpty) {
      final currentStats = stats.first;
      final updatedMatches = (currentStats['matches'] as int) + matches;
      final updatedWon = (currentStats['won'] as int) + won;
      final updatedLost = (currentStats['lost'] as int) + lost;
      final updatedTied = (currentStats['tied'] as int) + tied;

      // Update the stats in the database
      await db.update(
        'team_points',
        {
          'matches': updatedMatches,
          'won': updatedWon,
          'lost': updatedLost,
          'tied': updatedTied,
          'winPercentage':
              updatedMatches > 0 ? (updatedWon / updatedMatches) * 100 : 0.0,
        },
        where: 'team_id = ?',
        whereArgs: [teamId],
      );
    } else {
      // If no stats exist for the team, insert initial data
      await db.insert('team_points', {
        'team_id': teamId,
        'matches': matches,
        'won': won,
        'lost': lost,
        'tied': tied,
        'winPercentage': won > 0 ? (won / matches) * 100 : 0.0,
      });
    }
  }

  Future<void> addPlayerToTeam(int teamId, List<int> playerIds) async {
    Database db = await DatabaseHelper().database;
    Batch batch = db.batch();

    for (var playerId in playerIds) {
      batch.insert(
        'team_players',
        {'team_id': teamId, 'player_id': playerId},
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Player>> getAvailablePlayers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'players',
      where: 'isAvailable = ?',
      whereArgs: [1],
    );

    return result.map((map) => Player.fromMap(map)).toList();
  }

  // Get players by team ID
  Future<List<Player>> getPlayersByTeamId(int teamId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM $tablePlayers p
      INNER JOIN $tableTeamPlayers tp ON p.$columnId = tp.$columnPlayerId
      WHERE tp.$columnTeamId = ?
    ''', [teamId]);

    return maps.isNotEmpty
        ? maps.map((map) => Player.fromMap(map)).toList()
        : [];
  }

  // Get teams by player ID
  Future<List<Team>> getTeamsByPlayerId(int playerId) async {
    Database db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.* FROM $tableTeams t
      INNER JOIN $tableTeamPlayers tp ON t.$columnId = tp.$columnTeamId
      WHERE tp.$columnPlayerId = ?
    ''', [playerId]);

    return maps.isNotEmpty ? maps.map((map) => Team.fromMap(map)).toList() : [];
  }

  // Get player by ID
  Future<Player?> getPlayer(int id) async {
    Database db = await DatabaseHelper().database;
    var result =
        await db.query(tablePlayers, where: '$columnId = ?', whereArgs: [id]);
    return result.isNotEmpty ? Player.fromMap(result.first) : null;
  }

  // Get team by ID
  Future<Team?> getTeam(int id) async {
    Database db = await DatabaseHelper().database;
    var result =
        await db.query(tableTeams, where: '$columnId = ?', whereArgs: [id]);
    return result.isNotEmpty ? Team.fromMap(result.first) : null;
  }

  Future<void> updatePlayerStats(Map<String, dynamic> player) async {
    final db = await database;
    await db.update('players', player,
        where: 'name = ?', whereArgs: [player['name']]);
  }

  // In DatabaseHelper class
  Future<Player?> getPlayerByName(String playerName) async {
    final db = await database;

    // Assuming you have a table "players" with columns including "name"
    List<Map<String, dynamic>> maps = await db.query(
      'players',
      where: 'name = ?',
      whereArgs: [playerName],
    );

    if (maps.isNotEmpty) {
      return Player.fromMap(
          maps.first); // Assuming you have a fromMap method in Player
    }
    return null; // Return null if no player is found
  }

  // Fetch team performance stats from team_points table
  Future<Map<String, dynamic>> getTeamPerformance(int teamId) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> result = await db.query(
      'team_points',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // // Fetch all teams with their performance data
  // Future<List<Map<String, dynamic>>> getAllTeamsWithPerformance() async {
  //   final db = await database;
  //
  //   // Join the teams table with the team_points table to get performance stats for each team
  //   List<Map<String, dynamic>> result = await db.rawQuery('''
  //   SELECT t.teamName, t.logo, tp.matches, tp.won, tp.lost, tp.tied, tp.winPercentage
  //   FROM teams t
  //   INNER JOIN team_points tp ON t.id = tp.team_id
  // ''');
  //
  //   return result;
  // }

  // Get team information along with performance stats
  Future<Map<String, dynamic>> getTeamWithPerformance(int teamId) async {
    Database db = await DatabaseHelper().database;

    // Fetch team details
    List<Map<String, dynamic>> teamDetails = await db.query(
      'teams',
      where: 'id = ?',
      whereArgs: [teamId],
    );

    // Fetch team performance stats
    List<Map<String, dynamic>> teamPerformance = await db.query(
      'team_points',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );

    // Merge team details and performance data
    if (teamDetails.isNotEmpty && teamPerformance.isNotEmpty) {
      return {
        'team': teamDetails.first,
        'performance': teamPerformance.first,
      };
    }
    return {};
  }

  // Fetch all teams from the database
  Future<List<Team>> getAllTeams() async {
    Database db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableTeams);

    List<Team> teams = [];
    for (var map in maps) {
      teams.add(Team.fromMap(map));
    }
    return teams;
  }

  // Update an existing team
  Future<int> updateTeam(Team team) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      tableTeams,
      team.toMap(),
      where: '$columnId = ?',
      whereArgs: [team.id],
    );
  }

  // Delete player by ID
  Future<void> deletePlayer(int id) async {
    Database db = await DatabaseHelper().database;
    await db.delete(
      tablePlayers,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Delete team by ID
  Future<int> deleteTeam(int id) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(
      tableTeams,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Fetch players by team name
  Future<List<Player>> getPlayersByTeamName(String teamName) async {
    try {
      Database db = await DatabaseHelper().database;

      // First, get the team ID using the team name
      final List<Map<String, dynamic>> teamMaps = await db.query(
        tableTeams,
        where: '$columnTeamName = ?',
        whereArgs: [teamName],
      );

      if (teamMaps.isEmpty) {
        return []; // No team found with the provided name
      }

      // Get the team ID
      final int teamId = teamMaps.first[columnId];

      // Fetch players by team ID
      final List<Map<String, dynamic>> playerMaps = await db.rawQuery('''
      SELECT p.* FROM $tablePlayers p
      INNER JOIN $tableTeamPlayers tp ON p.$columnId = tp.$columnPlayerId
      WHERE tp.$columnTeamId = ? 
    ''', [teamId]);

      return playerMaps.map((map) => Player.fromMap(map)).toList();
    } catch (e) {
      print("Error fetching players by team name: $e");
      return [];
    }
  }

  Future<List<String>> fetchPlayersFromTeam(String teamName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'team_players',
      where: 'team_name = ?',
      whereArgs: [teamName],
    );
    return List<String>.from(maps.map((player) => player['name'] as String));
  }

  Future<List<Map<String, dynamic>>> getPlayersWithStatsByTeamId(
      int teamId) async {
    Database db = await DatabaseHelper().database;

    // Join the players table with the team_players junction table and the team_points table to get player stats
    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT p.*, tp.*, t.teamName, t.logo 
    FROM players p
    INNER JOIN team_players tp ON p.id = tp.player_id
    INNER JOIN teams t ON tp.team_id = t.id
    WHERE tp.team_id = ?
  ''', [teamId]);

    return result;
  }

  Future<void> updateTeamStats(
    String teamName,
    int matches,
    int won,
    int lost,
    int tied,
    double winPercentage,
  ) async {
    final db = await database;
    await db.update(
      'teams',
      {
        'matches': matches,
        'won': won,
        'lost': lost,
        'tied': tied,
        'winPercentage': winPercentage,
      },
      where: 'teamName = ?',
      whereArgs: [teamName],
    );
  }

  // Future<Team?> getTeamByName(String teamName) async {
  //   final db = await database;
  //
  //   List<Map<String, dynamic>> maps = await db.query(
  //     tableTeams,
  //     where: '$columnTeamName = ?',
  //     whereArgs: [teamName],
  //   );
  //
  //   if (maps.isNotEmpty) {
  //     return Team.fromMap(maps.first);
  //   }
  //   return null; // Return null if no team is found
  // }

  Future<int> deleteTeamPlayer(int teamId, int playerId) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(
      tableTeamPlayers,
      where: '$columnTeamId = ? AND $columnPlayerId = ?',
      whereArgs: [teamId, playerId],
    );
  }
}
