import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/fade_route.dart';
import 'login_screen.dart';
import 'post_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final _authService = AuthService();

  // Sample image URLs - replace with actual post data later
  final List<String> samplePosts = [
    'https://picsum.photos/800/600?random=1',
    'https://picsum.photos/800/600?random=2',
    'https://picsum.photos/800/600?random=3',
    'https://picsum.photos/800/600?random=4',
    'https://picsum.photos/800/600?random=5',
    'https://picsum.photos/800/600?random=6',
    'https://picsum.photos/800/600?random=7',
    'https://picsum.photos/800/600?random=8',
  ];

  HomeScreen({super.key, required this.user});

  Future<void> _handleLogout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        FadeRoute(page: const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TouchGrass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: samplePosts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostScreen(
                    imageUrl: samplePosts[index],
                  ),
                ),
              );
            },
            child: SizedBox(
              height: imageHeight,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.network(
                          samplePosts[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Failed to load image'),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Post ${index + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted by ${user.username}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post creation coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
