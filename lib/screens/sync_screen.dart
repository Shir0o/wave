import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme ? AppThemeColors.dark : AppThemeColors.light;

    // Health Connect Card Colors
    final connCardBg = state.healthConnectConnected
        ? const [Color(0xFF2FC4DC), Color(0xFF1F8FD0)]
        : [theme.text3, theme.text2];
    final connLabel = state.healthConnectConnected ? 'Connected & syncing' : 'Not connected';

    final otherApps = [
      {'name': 'Google Fit', 'status': 'Connected', 'color': theme.accent2},
      {'name': 'Samsung Health', 'status': 'Connect', 'color': theme.accent},
      {'name': 'Fitbit', 'status': 'Connect', 'color': theme.accent},
    ];

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
                'Health Connect',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: theme.text,
                ),
              ),
              const SizedBox(height: 16),
              // Health Connect status card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: connCardBg,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: state.healthConnectConnected
                          ? const Color(0xFF1F8FD0).withOpacity(0.28)
                          : theme.shadow,
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.22),
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Health Connect',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    connLabel,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: state.healthConnectConnected,
                            onChanged: (val) => state.toggleHealthConnect(),
                            activeColor: Colors.white,
                            activeTrackColor: Colors.white.withOpacity(0.35),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.35),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.2), height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last sync · ${state.lastSyncStr}',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: state.healthConnectConnected ? () => state.syncNow() : null,
                            icon: const Icon(Icons.sync_rounded, size: 17),
                            label: const Text('Sync now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: state.healthConnectConnected
                                  ? const Color(0xFF1F8FD0)
                                  : theme.text3,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Permissions Title
              Text(
                'PERMISSIONS',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              // Permissions box list
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.permissions.length,
                  separatorBuilder: (context, index) => Divider(
                    color: theme.divider2,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final perm = state.permissions[index];
                    final bool enabled = perm['enabled'] == true;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  perm['label'],
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.text,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  perm['desc'],
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
                            value: enabled,
                            onChanged: (val) => state.togglePermission(index),
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
              ),
              const SizedBox(height: 20),
              // Other Apps header
              Text(
                'OTHER APPS',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              // Other Apps list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherApps.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final app = otherApps[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        Text(
                          app['name'] as String,
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.text,
                          ),
                        ),
                        Text(
                          app['status'] as String,
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: app['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Replay setup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => state.navigateTo('onboard'),
                  icon: Icon(Icons.replay_rounded, color: theme.text2, size: 19),
                  label: const Text('Replay setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.surface,
                    foregroundColor: theme.text2,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    shadowColor: theme.shadow,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
