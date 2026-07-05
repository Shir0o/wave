import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme ? AppThemeColors.dark : AppThemeColors.light;

    // Find next reminder
    final nextReminderRow = state.reminders.firstWhere(
      (r) => r['enabled'] == true,
      orElse: () => {'time': 'None'},
    );
    final nextReminderStr = nextReminderRow['time'];

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Reminders',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
              Text(
                'Next splash at $nextReminderStr',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: theme.text2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              // Adaptive Reminders Banner
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F8FD0).withOpacity(0.32),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adaptive reminders',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'AI times each nudge around your intake, sleep window & activity.',
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.adaptiveReminders,
                      onChanged: (val) => state.toggleAdaptiveReminders(),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF0D94A6).withOpacity(0.3),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Settings Card (Active Hours + Intervals)
              Container(
                padding: const EdgeInsets.all(18.0),
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
                child: Column(
                  children: [
                    // Active hours
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bedtime_rounded, color: theme.accent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Active hours',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.text,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${state.wakeTime} – ${state.sleepTime}',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: theme.divider, height: 30),
                    // Interval selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_rounded, color: theme.accent, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Every',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.text,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => state.decrementInterval(),
                              icon: const Icon(Icons.remove, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.surfaceSoft,
                                foregroundColor: theme.accent2,
                                fixedSize: const Size(34, 34),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(minWidth: 56),
                              alignment: Alignment.center,
                              child: Text(
                                '${state.reminderInterval} min',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () => state.incrementInterval(),
                              icon: const Icon(Icons.add, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.surfaceSoft,
                                foregroundColor: theme.accent2,
                                fixedSize: const Size(34, 34),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Scheduled Times header
              Text(
                'SCHEDULED TIMES',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              // Scheduled Times list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.reminders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final row = state.reminders[index];
                  final bool enabled = row['enabled'] == true;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              color: enabled ? theme.accent : theme.text3,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              row['time'],
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: enabled ? theme.text : theme.text3,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: enabled,
                          onChanged: (val) => state.toggleReminderRow(index),
                          activeColor: Colors.white,
                          activeTrackColor: theme.accent,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: theme.trackOff,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
