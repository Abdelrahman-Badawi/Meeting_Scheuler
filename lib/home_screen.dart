import 'package:flutter/material.dart';
import 'create_user_screen.dart';
import 'upcoming_meetings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Scheduler'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateUserScreen(),
                  ),
                );
              },
              child: const Text('Create User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Enter User ID'),
                    content: TextField(
                      keyboardType: TextInputType.number,
                      onSubmitted: (value) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpcomingMeetingsScreen(
                              userId: int.parse(value),
                            ),
                          ),
                        );
                      },
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('View Meetings'),
            ),
          ],
        ),
      ),
    );
  }
}