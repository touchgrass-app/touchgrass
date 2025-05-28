import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../core/style/fade_route.dart';
import '../core/utils/result.dart';
import '../widgets/posts/post.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewmodel viewModel;
  HomeScreen({
    Key? key,
    HomeViewmodel? viewModel, // Make it nullable
  }) : viewModel = viewModel ?? HomeViewmodel(), // Provide a default value
        super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onLogOut);
    widget.viewModel.getUser.addListener(_onCacheUser);
  }
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.logout.removeListener(_onLogOut);
    oldWidget.viewModel.logout.removeListener(_onCacheUser);
    widget.viewModel.logout.addListener(_onLogOut);
    widget.viewModel.logout.addListener(_onCacheUser);
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onLogOut);
    widget.viewModel.logout.removeListener(_onCacheUser);
    super.dispose();
  }

  void _onLogOut() {
    if (widget.viewModel.logout.completed) {
      widget.viewModel.logout.clearResult();
      Navigator.push(
        context,
        FadeRoute(page: LoginScreen()),
      );
    }

    if (widget.viewModel.logout.error) {
      Result<dynamic> result = widget.viewModel.logout.result!;
      switch (result) {
        case Ok():
          break;
        case Error():
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result.error.toString().replaceFirst("Exception: ", "")), // Corrected property
          ));
          break;
      }
      widget.viewModel.logout.clearResult();
    }
  }

  void _onCacheUser() {
    if (widget.viewModel.getUser.completed) {
      widget.viewModel.getUser.clearResult();
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
            key: const ValueKey('LogoutButton'),
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => widget.viewModel.logout.execute(),
          ),
        ],
      ),
      body:  ListenableBuilder(
    listenable: widget.viewModel.getUser,
    builder: (context, child) {
      if (widget.viewModel.getUser.running) {
        return const CircularProgressIndicator();
      }
      else if (widget.viewModel.getUser.error == false){
        return ListView.builder(
          itemCount: widget.viewModel.posts.length,
          itemBuilder: (context, index) {
          return SizedBox(
              height: postHeight,
              child: Post(
                imageUrl: widget.viewModel.samplePosts[index],
                username: widget.viewModel.user?.username??"Unknown",
                title: 'Post ${index + 1}',
              ),
          );
          }
        );
      }
      return const Center(
        child: Text("Something went wrong"),
      );
    }),
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
