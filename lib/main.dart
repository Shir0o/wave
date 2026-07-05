import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wave/screens/home_screen.dart';
import 'package:wave/screens/onboarding_screen.dart';
import 'package:wave/screens/reminders_screen.dart';
import 'package:wave/screens/smart_log_screen.dart';
import 'package:wave/screens/sync_screen.dart';
import 'package:wave/screens/trends_screen.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const WaveApp(),
    ),
  );
}

class WaveApp extends StatelessWidget {
  const WaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme ? AppThemeColors.dark : AppThemeColors.light;

    return MaterialApp(
      title: 'Wave - Hydration Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: state.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: theme.bg,
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: theme.bg,
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme ? AppThemeColors.dark : AppThemeColors.light;

    // Handle full-screen transitions outside bottom nav
    if (state.currentScreen == 'onboard') {
      return const OnboardingScreen();
    } else if (state.currentScreen == 'log') {
      return const SmartLogScreen();
    }

    Widget body;
    switch (state.currentScreen) {
      case 'home':
        body = const HomeScreen();
        break;
      case 'reminders':
        body = const RemindersScreen();
        break;
      case 'stats':
        body = const TrendsScreen();
        break;
      case 'sync':
        body = const SyncScreen();
        break;
      default:
        body = const HomeScreen();
    }

    return Scaffold(
      backgroundColor: theme.bg,
      body: Stack(
        children: [
          // Active Page Body
          body,
          // Toast Notification Overlay
          if (state.toastMessage != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  builder: (context, val, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - val)),
                      child: Opacity(
                        opacity: val,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.toastBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      state.toastMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        color: theme.toastText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Floating central smart log button
      floatingActionButton: FloatingActionButton(
        onPressed: () => state.navigateTo('log'),
        elevation: 0,
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.surface, width: 4),
            gradient: const LinearGradient(
              colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F8FD0).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Custom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: theme.surface,
        elevation: 0,
        height: 72,
        padding: EdgeInsets.zero,
        notchMargin: 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withOpacity(0.09),
                blurRadius: 26,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  context,
                  screenName: 'home',
                  icon: Icons.home_rounded,
                  label: 'Home',
                  theme: theme,
                  state: state,
                ),
                _buildNavItem(
                  context,
                  screenName: 'reminders',
                  icon: Icons.notifications_rounded,
                  label: 'Reminders',
                  theme: theme,
                  state: state,
                ),
                const SizedBox(width: 48), // spacer for central FAB
                _buildNavItem(
                  context,
                  screenName: 'stats',
                  icon: Icons.bar_chart_rounded,
                  label: 'Trends',
                  theme: theme,
                  state: state,
                ),
                _buildNavItem(
                  context,
                  screenName: 'sync',
                  icon: Icons.favorite_rounded,
                  label: 'Sync',
                  theme: theme,
                  state: state,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String screenName,
    required IconData icon,
    required String label,
    required AppThemeColors theme,
    required AppState state,
  }) {
    final bool isSelected = state.currentScreen == screenName;
    final color = isSelected ? theme.accent : theme.text3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => state.navigateTo(screenName),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.fredoka(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
