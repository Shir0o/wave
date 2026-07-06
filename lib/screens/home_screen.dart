import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wave/models/drink_entry.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';
import 'package:wave/utils/icon_helper.dart';
import 'package:wave/widgets/wave_painter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme
        ? AppThemeColors.dark
        : AppThemeColors.light;

    final todayConsumed = state.totalConsumedToday;
    final pct = (todayConsumed / state.goalOz * 100).clamp(0.0, 100.0).round();
    final fillPercentage = (todayConsumed / state.goalOz).clamp(0.0, 1.0);

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    final todayEntries = state.entries
        .where((e) {
          final t = e.time;
          return t.year == now.year && t.month == now.month && t.day == now.day;
        })
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: theme.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wave & Stats Header
            Stack(
              children: [
                // Animated Wave Container
                SizedBox(
                  height: 398,
                  child: WaveContainer(
                    fillPercentage: fillPercentage,
                    fillTopColor: theme.fillTop,
                    fillBottomColor: theme.fillBot,
                    waveColor1: theme.wave1,
                    waveColor2: theme.wave2,
                  ),
                ),
                // Header Top Bar overlays
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.text2,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                greeting,
                                style: GoogleFonts.fredoka(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Theme Toggle
                              IconButton(
                                onPressed: () => state.toggleTheme(),
                                icon: Icon(
                                  state.isDarkTheme
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: theme.accent,
                                  size: 22,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.surface,
                                  shadowColor: theme.shadow,
                                  elevation: 4,
                                  fixedSize: const Size(44, 44),
                                ),
                              ),
                              const SizedBox(width: 9),
                              // Health Connect Navigate
                              IconButton(
                                onPressed: () => state.navigateTo('sync'),
                                icon: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.surface,
                                  shadowColor: theme.shadow,
                                  elevation: 4,
                                  fixedSize: const Size(44, 44),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Center Percentage Metrics
                Positioned.fill(
                  child: IgnorePointer(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'TODAY',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.onWave,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: theme.onWaveSh,
                                offset: const Offset(0, 2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$pct',
                              style: GoogleFonts.fredoka(
                                fontSize: 82,
                                fontWeight: FontWeight.w600,
                                color: theme.onWave,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: theme.onWaveSh,
                                    offset: const Offset(0, 4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '%',
                              style: GoogleFonts.fredoka(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: theme.onWave,
                                shadows: [
                                  Shadow(
                                    color: theme.onWaveSh,
                                    offset: const Offset(0, 4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${todayConsumed.round()} of ${state.goalOz.round()} fl oz',
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: theme.onWave,
                            shadows: [
                              Shadow(
                                color: theme.onWaveSh,
                                offset: const Offset(0, 2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Lower Content Overlay (Quick Adds and Drinks List)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  // Quick Add Buttons with negative margin overlap
                  Transform.translate(
                    offset: const Offset(0, -26),
                    child: Row(
                      children: [
                        _buildQuickAddBtn(
                          context,
                          theme: theme,
                          icon: Icons.local_drink_rounded,
                          title: 'Glass',
                          vol: '8 oz',
                          onTap: () => state.quickAddGlass(),
                        ),
                        const SizedBox(width: 9),
                        _buildQuickAddBtn(
                          context,
                          theme: theme,
                          icon: Icons.opacity_rounded,
                          title: 'Bottle',
                          vol: '16 oz',
                          onTap: () => state.quickAddBottle(),
                        ),
                        const SizedBox(width: 9),
                        _buildQuickAddBtn(
                          context,
                          theme: theme,
                          icon: Icons.local_cafe_rounded,
                          title: 'Coffee',
                          vol: '12 oz',
                          onTap: () => state.quickAddCoffee(),
                        ),
                      ],
                    ),
                  ),
                  // Smart Log Banner
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1F8FD0).withOpacity(0.35),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => state.navigateTo('log'),
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 26,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Smart log',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '"a large latte and two waters"',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Today's list header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's drinks",
                        style: GoogleFonts.fredoka(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                      Text(
                        '${(todayConsumed / 8.0).toStringAsFixed(1)} cups',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.text2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Today's list entries
                  if (todayEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No drinks logged yet.',
                        style: GoogleFonts.fredoka(
                          color: theme.text3,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayEntries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = todayEntries[index];
                        return _buildDrinkItem(context, entry, theme);
                      },
                    ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddBtn(
    BuildContext context, {
    required AppThemeColors theme,
    required IconData icon,
    required String title,
    required String vol,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2589CF).withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 4,
              ),
              child: Column(
                children: [
                  Icon(icon, color: theme.accent, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    vol,
                    style: GoogleFonts.fredoka(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.text3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkItem(
    BuildContext context,
    DrinkEntry entry,
    AppThemeColors theme,
  ) {
    final state = Provider.of<AppState>(context, listen: false);
    final timeStr = DateFormat('h:mm a').format(entry.time);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        state.removeEntry(entry.id);
        state.showToast('Removed ${entry.name}');
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2589CF).withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.surfaceSoft,
              ),
              child: Icon(
                getIconData(entry.icon),
                color: theme.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.text,
                    ),
                  ),
                  Text(
                    '$timeStr · ${entry.source}',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: theme.text3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.oz.round()} oz',
              style: GoogleFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
