import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:home_maintenance/languages/ar.dart';
import 'package:home_maintenance/screens/home/cart.dart';
import 'package:home_maintenance/screens/home/products.dart';
import 'package:home_maintenance/screens/home/settings.dart';
import 'package:home_maintenance/screens/splash_screen/splash_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.page_index = 0});

  final int page_index;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const Products(),
    const Cart(),
    const Settings(),
  ];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Set the initial index based on the provided page_index
    _currentIndex = widget.page_index;
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, email TEXT, password TEXT)',
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await _database.delete('users');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SlideTransition(
        position: _slideAnimation,
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: _buildDrawer(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      title: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 500),
        style: GoogleFonts.cairo(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        child: const Text(Ar.appName),
      ),
      centerTitle: true,
      elevation: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedLabelStyle: GoogleFonts.cairo(),
      unselectedLabelStyle: GoogleFonts.cairo(),
      backgroundColor: backgroundColor,
      onTap: _onTabTapped,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: Ar.products,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: Ar.cart,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: Ar.settings,
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Adjusted to receive context
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: backgroundColor,
            ),
            child: Center(
              child: Text(
                Ar.appName,
                style: GoogleFonts.cairo(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _buildDrawerListTile(
            icon: Icons.home_outlined,
            title: Ar.products,
            onTap: () {
              _onTabTapped(0);
              Navigator.of(context).pop();
            },
          ),
          _buildDrawerListTile(
            icon: Icons.shopping_cart_outlined,
            title: Ar.cart,
            onTap: () {
              _onTabTapped(1);
              Navigator.of(context).pop();
            },
          ),
          _buildDrawerListTile(
            icon: Icons.settings_outlined,
            title: Ar.settings,
            onTap: () {
              _onTabTapped(2);
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: _buildDrawerListTile(
              icon: Icons.logout,
              title: Ar.logout,
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}
