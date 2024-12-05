import 'package:flutter/material.dart';

class NewTournamentScreen extends StatefulWidget {
  @override
  _NewTournamentScreenState createState() => _NewTournamentScreenState();
}

class _NewTournamentScreenState extends State<NewTournamentScreen> {
  int overs = 1;
  int players = 2;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _tournamentNameController = TextEditingController();
  TextEditingController _teamsController = TextEditingController();
  TextEditingController _venueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text('New Tournament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of Overs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No. of Overs', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (overs > 1) overs--;
                          });
                        },
                      ),
                      Text('$overs', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            overs++;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),

              // Number of Players
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No. of Players', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (players > 2) players--;
                          });
                        },
                      ),
                      Text('$players', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (players < 11) players++;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),

              // Tournament Name
              TextFormField(
                controller: _tournamentNameController,
                decoration: InputDecoration(labelText: 'Tournament Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a tournament name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Number of Teams
              TextFormField(
                controller: _teamsController,
                decoration:
                    InputDecoration(labelText: 'No. of Teams (min 2, max 100)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter number of teams';
                  }
                  int? teams = int.tryParse(value);
                  if (teams == null || teams < 2 || teams > 100) {
                    return 'Teams should be between 2 and 100';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Venue Name
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(labelText: 'Venue Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a venue name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),

              // Continue Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed further
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tournament Created: ${_tournamentNameController.text}',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
