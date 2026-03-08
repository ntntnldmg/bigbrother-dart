import 'package:flutter/material.dart';
import '../models/citizen.dart';
import '../game/game_state.dart';

class CitizenPanel extends StatelessWidget {
  final GameState gameState;

  const CitizenPanel({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        border: Border(right: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white10,
            width: double.infinity,
            child: const Text(
              'Citizens Database',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.todayCitizens.length,
              itemBuilder: (context, index) {
                final citizen = gameState.todayCitizens[index];
                return ListTile(
                  title: Text(
                    'ID: ${citizen.idNumber}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${citizen.occupation} • Age: ${citizen.ageGroup}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => _showCitizenDetails(context, citizen),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCitizenDetails(BuildContext context, Citizen citizen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Citizen Details: ${citizen.idNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Age Group: ${citizen.ageGroup}'),
              Text('Occupation: ${citizen.occupation}'),
              Text('Religion: ${citizen.religion}'),
              Text('Ethnicity: ${citizen.ethnicity}'),
              const SizedBox(height: 20),
              // Risk score deliberately omitted from player view
              const Text(
                'Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      gameState.investigateCitizen();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Investigate'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      gameState.detainCitizen();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Detain'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
