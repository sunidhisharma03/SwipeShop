import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swipeshop_frontend/Home/home.dart';
import 'package:swipeshop_frontend/Inbox/inbox.dart';
import 'package:swipeshop_frontend/Search/search.dart';
import 'package:swipeshop_frontend/test/test.dart';
import 'firebase_options.dart';
import 'package:swipeshop_frontend/Home/newHome.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IndexPage(),
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Swipe Shop",
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // Swipe right
            setState(() {
              _selectedIndex = (_selectedIndex - 1).clamp(0, 2);
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          } else if (details.primaryVelocity! < 0) {
            // Swipe left
            setState(() {
              _selectedIndex = (_selectedIndex + 1).clamp(0, 2);
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children:  [
            Search(),
            // Home(),
            VideoListScreen(),
            Inbox(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: const TextStyle(color: Colors.white),
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        unselectedFontSize: 14,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.search_favorite),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.direct_inbox),
            label: 'Inbox',
          ),
        ],
        backgroundColor: Colors.black,
      ),
    );
  }
}
