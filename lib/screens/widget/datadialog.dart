import 'package:flutter/material.dart';

class ManageDataDialog extends StatelessWidget {
  const ManageDataDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Manage Your Data", style: TextStyle(fontSize: 18),),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Import Data
          _buildDataOption(
            context,
            icon: Icons.download,
            label: "Import Data",
            color: Colors.pink,
            onTap: () {
              // Handle import data action here
            },
          ),
          // Export Data
          _buildDataOption(
            context,
            icon: Icons.upload,
            label: "Export Data",
            color: Colors.green,
            onTap: () {
              // Handle export data action here
            },
          ),
          // Erase Data
          _buildDataOption(
            context,
            icon: Icons.delete,
            label: "Erase Data",
            color: Colors.red,
            onTap: () {
              // Handle erase data action here
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create each data option widget
  Widget _buildDataOption(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 28,
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// To show the dialog, call this function
// Show Manage Data dialog
void showManageDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ManageDataDialog(); // Use your custom dialog widget
    },
  );
}

