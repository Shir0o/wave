import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wave/state/app_state.dart';
import 'package:wave/theme/app_theme.dart';
import 'package:wave/utils/icon_helper.dart';

class SmartLogScreen extends StatefulWidget {
  const SmartLogScreen({super.key});

  @override
  State<SmartLogScreen> createState() => _SmartLogScreenState();
}

class _SmartLogScreenState extends State<SmartLogScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _waveAnimController;

  final List<String> _chips = [
    'a venti oat latte',
    'two glasses of water',
    '500 ml sparkling water',
    '16 oz cold brew',
    'herbal tea mug',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = state.isDarkTheme
        ? AppThemeColors.dark
        : AppThemeColors.light;

    // Sync state text with controller
    if (state.aiText != _controller.text && !state.aiListening) {
      _controller.text = state.aiText;
    }

    final hasResult =
        state.aiResult != null && state.aiResult!.items.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      state.clearAi();
                      state.navigateTo('home');
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.surface,
                      foregroundColor: theme.text,
                      shadowColor: theme.shadow,
                      elevation: 4,
                      fixedSize: const Size(44, 44),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart log',
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.text,
                        ),
                      ),
                      Text(
                        'Just describe your drink',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.text2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Search/Input Box
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadow,
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      onChanged: (text) => state.setAiText(text),
                      decoration: InputDecoration(
                        hintText: 'a venti latte and two glasses of water',
                        hintStyle: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.text3,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Voice mic button
                        IconButton(
                          onPressed: () => state.triggerVoiceSim(),
                          icon: Icon(Icons.mic_rounded, color: theme.accent2),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.surfaceSoft,
                            fixedSize: const Size(46, 46),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Photo trigger
                        IconButton(
                          onPressed: () => state.triggerPhotoSim(),
                          icon: Icon(
                            Icons.photo_camera_rounded,
                            color: theme.accent2,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.surfaceSoft,
                            fixedSize: const Size(46, 46),
                          ),
                        ),
                        const Spacer(),
                        // Send/Parse Action
                        GestureDetector(
                          onTap: () => state.setAiText(_controller.text),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF2FC4DC), Color(0xFF1F8FD0)],
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Listening animation helper
                    if (state.aiListening) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildListeningBar(0),
                          _buildListeningBar(0.2),
                          _buildListeningBar(0.4),
                          const SizedBox(width: 8),
                          Text(
                            'Listening...',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.accent2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Chips Trigger Header
              Text(
                'TRY SAYING',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              // Suggestions Row Wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _chips.map((label) {
                  return InkWell(
                    onTap: () {
                      state.setAiText(label);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.accent2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              // Results Display Box
              if (hasResult)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(26),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: theme.accent2,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Here's what I got",
                                style: GoogleFonts.fredoka(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.text,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surfaceSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(state.aiResult!.confidence * 100).round()}% match',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.accent2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // List parsed items
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.aiResult!.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final it = state.aiResult!.items[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surfaceTint,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: theme.surfaceSoft,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    getIconData(it.icon),
                                    color: theme.accent2,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        it.name,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.text,
                                        ),
                                      ),
                                      Text(
                                        '${it.oz.round()} oz · ${(it.factor * 100).round()}% hydration',
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
                                  '+${it.hydration.round()}',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.accent2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Total sum label
                      Text(
                        '${state.aiResult!.oz.round()} oz total · counts as +${state.aiResult!.hydration.round()} oz water',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          color: theme.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => state.clearAi(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: theme.divider,
                                foregroundColor: theme.text2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.fredoka(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => state.confirmAiLog(),
                              style:
                                  ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ).copyWith(
                                    elevation: ButtonStyleButton.allOrNull(0),
                                  ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2FC4DC),
                                      Color(0xFF1F8FD0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1F8FD0,
                                      ).withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Log all drinks',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningBar(double delay) {
    return AnimatedBuilder(
      animation: _waveAnimController,
      builder: (context, child) {
        final val = math.sin(
          (_waveAnimController.value * 2 * math.pi) + delay * 10,
        );
        final height = 6.0 + (val.abs() * 10.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0D94A6),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
