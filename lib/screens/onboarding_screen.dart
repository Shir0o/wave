import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme
        ? AppThemeColors.dark
        : AppThemeColors.light;

    return Scaffold(
      backgroundColor: theme.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.heroBot, theme.bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 26.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F8FD0).withOpacity(0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Heading
                Text(
                  'Ride your\nhydration wave.',
                  style: GoogleFonts.fredoka(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                // Subheading
                Text(
                  'Log any drink in plain words, catch smart nudges, and sync straight to Health Connect.',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.text2,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 26),
                // Goal Card
                Container(
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadow,
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DAILY GOAL',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.text3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Minus Button
                          IconButton(
                            onPressed: () => state.adjustOnbGoal(-8),
                            icon: const Icon(Icons.remove, size: 24),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.surfaceSoft,
                              foregroundColor: theme.accent2,
                              fixedSize: const Size(48, 48),
                            ),
                          ),
                          const SizedBox(width: 22),
                          // Goal Text
                          Column(
                            children: [
                              Text(
                                '${state.onbGoal.round()}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '≈ ${(state.onbGoal / 8.0).round()} cups a day',
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.text3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 22),
                          // Plus Button
                          IconButton(
                            onPressed: () => state.adjustOnbGoal(8),
                            icon: const Icon(Icons.add, size: 24),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.surfaceSoft,
                              foregroundColor: theme.accent2,
                              fixedSize: const Size(48, 48),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Health Connect Consent Tile
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadow,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: theme.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sync to Health Connect',
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.text,
                              ),
                            ),
                            Text(
                              'Recommended',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                color: theme.text3,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.onbConnect,
                        onChanged: (val) => state.toggleOnbConnect(),
                        activeColor: Colors.white,
                        activeTrackColor: theme.accent,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: theme.trackOff,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Start Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => state.finishOnboarding(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F8FD0).withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Dive in',
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
