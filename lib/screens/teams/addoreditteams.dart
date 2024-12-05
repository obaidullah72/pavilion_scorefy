import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../database/db_helper.dart';
import '../../database/team_model.dart';

class AddEditTeamScreen extends StatefulWidget {
  final Team? team; // Optional team for editing (null means adding a new team)

  AddEditTeamScreen({this.team});

  @override
  _AddEditTeamScreenState createState() => _AddEditTeamScreenState();
}

class _AddEditTeamScreenState extends State<AddEditTeamScreen> {
  final _teamNameController = TextEditingController();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    if (widget.team != null) {
      // If editing, pre-fill the team data
      _teamNameController.text = widget.team!.teamName;
      _logoPath = widget.team!.logo;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  Future<void> _saveTeam() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty || _logoPath == null) {
      // Show error if name or logo is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide both team name and logo.')),
      );
      return;
    }

    // Create the Team object
    Team newTeam = Team(teamName: teamName, logo: _logoPath!);

    if (widget.team == null) {
      // Insert new team
      await DatabaseHelper.instance.insertTeam(newTeam);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Team Added",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 500),
        ),
      );
      print('Team Added');
    } else {
      // Update existing team
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Team Updated",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 500),
        ),
      );
      newTeam.id = widget.team!.id;
      await DatabaseHelper.instance.updateTeam(newTeam);
      print('Team Updated');

    }

    Navigator.pop(context);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text(widget.team == null ? 'Add New Team' : 'Edit Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(labelText: 'Team Name'),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _logoPath == null
                  ? CircleAvatar(
                radius: 50, // Controls the size of the circular avatar
                backgroundColor: Colors.grey[200], // Default background color when no image
                child: Icon(Icons.add_a_photo, size: 40), // Icon for image pick
              )
                  : CircleAvatar(
                radius: 50, // Controls the size of the circular avatar
                backgroundImage: FileImage(File(_logoPath!)), // Load the image from the local file path
                backgroundColor: Colors.transparent, // Transparent background
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: _saveTeam,
              child: Text(widget.team == null ? 'Add Team' : 'Update Team'),
            ),
          ],
        ),
      ),
    );
  }
}
