import 'package:flutter/material.dart';
import '../models/user.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TouchGrass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.username}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}'),
                    if (user.firstName != null) Text('First Name: ${user.firstName}'),
                    if (user.lastName != null) Text('Last Name: ${user.lastName}'),
                    Text('Member since: ${user.createdAt.toString().split('T')[0]}'),
                    if (user.lastLogin != null)
                      Text('Last login: ${user.lastLogin.toString().split('T')[0]}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Habits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('No habits yet. Start by creating one!'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement habit creation
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 