// lib/features/home/main_screen.dart
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // List of your pages
  final List<Widget> _pages = [
    const HomePage(),      // Your homepage content
    const ChatPage(),      // To be built later
    const FavouritePage(), // To be built later
    const ShelvesPage(),   // To be built later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Shows current page
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Switches page
          });
        },
      ),
    );
  }
}