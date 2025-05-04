import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../core/services/auth_service.dart';
import '../core/style/fade_route.dart';
import '../widgets/posts/post.dart';
import 'login_screen.dart';

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
    final postHeight = screenHeight * 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242424),
        title: const Text(
          'TouchGrass',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: samplePosts.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: postHeight,
            child: Post(
              imageUrl: samplePosts[index],
              username: user.username,
              title: 'Post ${index + 1}',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post creation coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
