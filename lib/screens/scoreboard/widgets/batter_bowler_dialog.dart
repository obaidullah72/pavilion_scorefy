import 'package:flutter/material.dart';
import '../../../database/db_helper.dart';

class SelectBattersAndBowlerDialog extends StatefulWidget {
  final DatabaseHelper database;
  final String teamA;
  final String teamB;
  final Function(List<Map<String, dynamic>>, List<Map<String, dynamic>>) onPlayersSelected;

  SelectBattersAndBowlerDialog({
    required this.database,
    required this.teamA,
    required this.teamB,
    required this.onPlayersSelected,
  });

  @override
  _SelectBattersAndBowlerDialogState createState() =>
      _SelectBattersAndBowlerDialogState();
}

class _SelectBattersAndBowlerDialogState
    extends State<SelectBattersAndBowlerDialog> {
  String? selectedBatter1;
  String? selectedBatter2;
  String? selectedBowler;

  List<String> teamAPlayers = [];
  List<String> teamBPlayers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final teamA = await widget.database.getPlayersByTeamName(widget.teamA);
      final teamB = await widget.database.getPlayersByTeamName(widget.teamB);

      setState(() {
        teamAPlayers = teamA.map((player) => player.name!).toList();
        teamBPlayers = teamB.map((player) => player.name!).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.green,
      title: const Text(
        'Select Batters and Bowler',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown("Select Batter 1", teamAPlayers, selectedBatter1,
                    (newValue) {
                  setState(() {
                    selectedBatter1 = newValue;
                  });
                }),
            _buildDropdown("Select Batter 2", teamAPlayers, selectedBatter2,
                    (newValue) {
                  setState(() {
                    selectedBatter2 = newValue;
                  });
                }),
            _buildDropdown("Select Bowler", teamBPlayers, selectedBowler,
                    (newValue) {
                  setState(() {
                    selectedBowler = newValue;
                  });
                }),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {
            if (_validateSelections()) {
              // Create data for batsmen and bowler
              final selectedBatters = [
                {'name': selectedBatter1, 'r': 0, 'b': 0, '4s': 0, '6s': 0, 'sr': 0.0},
                {'name': selectedBatter2, 'r': 0, 'b': 0, '4s': 0, '6s': 0, 'sr': 0.0},
              ];
              final selectedBowlers = [
                {'name': selectedBowler, 'o': 0, 'm': 0, 'r': 0, 'w': 0, 'econ': 0.0},
              ];

              // Pass data to parent via callback
              widget.onPlayersSelected(selectedBatters, selectedBowlers);

              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select all players')),
              );
            }
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String hint, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    // Create a filtered list based on the current hint and other selections
    List<String> filteredItems = List.from(items);

    if (hint == "Select Batter 1" && selectedBatter2 != null) {
      filteredItems.remove(selectedBatter2); // Remove Batter 2 from Batter 1's list
    } else if (hint == "Select Batter 2" && selectedBatter1 != null) {
      filteredItems.remove(selectedBatter1); // Remove Batter 1 from Batter 2's list
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(hint, style: TextStyle(color: Colors.grey[700])),
            value: selectedItem,
            onChanged: onChanged,
            isExpanded: true,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
            items: filteredItems.map((String player) {
              return DropdownMenuItem<String>(
                value: player,
                child: Text(
                  player,
                  style: const TextStyle(color: Colors.green),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }


  bool _validateSelections() {
    return selectedBatter1 != null &&
        selectedBatter2 != null &&
        selectedBowler != null;
  }
}
