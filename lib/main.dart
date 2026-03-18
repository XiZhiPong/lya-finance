import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/savings_goals_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const LyaFinanceApp());
}

class LyaFinanceApp extends StatelessWidget {
  const LyaFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lya Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6B4EE6),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1A2E),
          background: Color(0xFF0A0A0F),
        ),
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const BudgetScreen(),
    const SavingsGoalsScreen(),
    const SettingsScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.savings_rounded,
    Icons.settings_rounded,
  ];

  final List<String> _labels = ['Home', 'Budget', 'Goals', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _icons.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? const Color(0xFF6B4EE6) : Colors.white54;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icons[index], size: 24, color: color),
              const SizedBox(height: 4),
              Text(_labels[index], style: TextStyle(color: color, fontSize: 10)),
            ],
          );
        },
        backgroundColor: const Color(0xFF1A1A2E),
        activeIndex: _currentIndex,
        splashColor: const Color(0xFF6B4EE6),
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.none,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        elevation: 8,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
