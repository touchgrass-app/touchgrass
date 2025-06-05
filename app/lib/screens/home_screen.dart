import 'package:flutter/material.dart';
import '../viewmodels/home_viewmodel.dart';
import '../core/style/fade_route.dart';
import '../core/utils/result.dart';
import '../widgets/posts/post.dart';
import 'login_screen.dart';

// TODO: create settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: const Center(
        child: Text('Settings Screen - Coming Soon!'),
      ),
    );
  }
}

class AppColors {
  static const scaffoldBackground = Color(0xFF1A1A1A);
  static const appBarBackground = Color(0xFF242424);
  static const fabBackground = Color(0xFF4CAF50);
  static const menuBackground = Color(0xFF2C2C2C);
}

// Define menu item enum for clarity
enum MenuItem { settings, logout }

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  final HomeViewmodel viewModel = HomeViewmodel();
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
            content: Text(result.error.toString().replaceFirst(
                "Exception: ", "")), // Corrected property
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

  AppBar _buildAppBar (BuildContext context){
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      title: const Text(
        'TouchGrass',
        style: TextStyle(color: Colors.white70),
      ),
      actions:[
        PopupMenuButton<MenuItem>(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu, color: Colors.white70),
          offset: const Offset(0, 56), // Positions menu below AppBar (56 is typical AppBar height)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          color: AppColors.menuBackground, // Matches dark theme
          elevation: 8, // Subtle shadow for depth
          onSelected: (MenuItem item) {
            switch (item) {
              case MenuItem.settings:
                Navigator.push(
                  context,
                  FadeRoute(page: const SettingsScreen()),
                );
                break;
              case MenuItem.logout:
                widget.viewModel.logout.execute();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
            const PopupMenuItem<MenuItem>(
              value: MenuItem.settings,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const PopupMenuItem<MenuItem>(
              value: MenuItem.logout,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListenableBuilder _buildBody (BuildContext context, double postHeight){
    return ListenableBuilder(
      listenable: widget.viewModel.getUser,
      builder: (context, child) {
        if (widget.viewModel.getUser.running) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: widget.viewModel.posts.length,
          itemBuilder: (context, index) {
            return SizedBox(
              height: postHeight,
              child: Post(
                imageUrl: widget.viewModel.samplePosts[index],
                username: widget.viewModel.user?.username ?? "Unknown",
                title: 'Post ${index + 1}',
              ),
            );
          },
        );
      },
    );
  }

  FloatingActionButton _buildPostButton (BuildContext context){
    return FloatingActionButton(
      backgroundColor: AppColors.fabBackground,
      onPressed: () {
        // TODO: Implement post creation functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post creation coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: const Icon(Icons.add_a_photo, color: Colors.white),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final postHeight = screenHeight * 0.7;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body: _buildBody(context,postHeight),
      floatingActionButton: _buildPostButton(context),
    );
  }

}
