// lib/features/core/main_shell.dart
// Improved MainShell: centered, responsive glass nav, drawer/keyboard aware,
// exposes navBaseHeight for pages to reserve bottom space.
// NAV BAR MADE SHORTER: navBaseHeight = 90.0 and visual sizes/paddings reduced.

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainShell extends StatefulWidget {
  final List<Widget> pages;
  final Widget? drawer;

  const MainShell({super.key, required this.pages, this.drawer});

  // Base nav height used by pages to reserve padding (avoid overlap).
  // Reduced so the nav appears more compact on-screen.
  static const double navBaseHeight = 90.0;

  // global scaffold key so pages can open the drawer reliably:
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _navController;
  late final AnimationController _activeAnim;
  late final AnimationController _particleController;
  late final AnimationController _glowController;

  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      value: 1.0,
    );
    _activeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1.0;
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _navController.dispose();
    _activeAnim.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  int get safeIndex {
    if (widget.pages.isEmpty) return 0;
    if (_index < 0) return 0;
    if (_index >= widget.pages.length) return widget.pages.length - 1;
    return _index;
  }

  bool _keyboardOpen(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  // update nav visibility when keyboard or drawer changes
  void _updateNavVisibility(BuildContext context) {
    final shouldHide = _drawerOpen || _keyboardOpen(context);
    if (shouldHide) {
      _navController.reverse();
    } else {
      _navController.forward();
      _activeAnim.forward(from: 0.0).then((_) => _activeAnim.reverse());
    }
  }

  // pages can call this if they open/close drawer themselves
  void notifyDrawerState(bool open) {
    _drawerOpen = open;
    _updateNavVisibility(context);
  }

  void _setIndex(int idx) {
    if (idx == safeIndex) {
      HapticFeedback.selectionClick();
      _activeAnim.forward(from: 0.0).then((_) => _activeAnim.reverse());
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _index = idx);
    _activeAnim.forward(from: 0.0).then((_) => _activeAnim.reverse());
  }

  @override
  Widget build(BuildContext context) {
    // respond to keyboard changes
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateNavVisibility(context),
    );

    return Scaffold(
      key: MainShell.scaffoldKey,
      drawer: widget.drawer,
      extendBody: true,
      onDrawerChanged: (isOpen) {
        _drawerOpen = isOpen;
        _updateNavVisibility(context);
      },
      body: Stack(
        children: [
          // pages (AnimatedSwitcher for smooth transitions)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(safeIndex),
              child: widget.pages.isNotEmpty
                  ? widget.pages[safeIndex]
                  : const SizedBox.shrink(),
            ),
          ),

          // nav overlay (use AnimatedBuilder on _navController)
          AnimatedBuilder(
            animation: _navController,
            builder: (context, _) {
              final v = _navController.value; // 0..1
              final bottom = lerpDouble(
                -140,
                12,
                v,
              )!; // moved slightly up and reduced offset
              return Positioned(
                left: 0,
                right: 0,
                bottom: bottom,
                child: Opacity(
                  opacity: v,
                  // constrain nav width so it centers predictably on all screen sizes
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final navWidth = math.min(
                          maxWidth * 0.92,
                          560.0,
                        ); // slightly narrower max width
                        // IMPORTANT: pass navWidth into the nav widget and make that widget
                        // occupy the full width so children can be spaced evenly.
                        return SizedBox(
                          width: navWidth,
                          child: _buildStunningNavigation(
                            context,
                            width: navWidth,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Now accept width and ensure internal container fills that width and uses spaceEvenly
  Widget _buildStunningNavigation(
    BuildContext context, {
    required double width,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // glow
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, _) {
            return Container(
              width: math.min(width, 440), // reduced max glow width
              height: 64 + (_glowController.value * 6), // reduced height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(
                      0.12 + (_glowController.value * 0.06),
                    ),
                    blurRadius: 30 + (_glowController.value * 8),
                    spreadRadius: 1.5,
                  ),
                ],
              ),
            );
          },
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(40), // slightly tighter radius
          child: Stack(
            children: [
              // animated gradient background
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.06),
                          primary.withOpacity(0.11),
                          primary.withOpacity(0.05),
                        ],
                        begin: Alignment(
                          -1 + (_particleController.value * 2),
                          -1,
                        ),
                        end: Alignment(1 - (_particleController.value * 2), 1),
                      ),
                    ),
                  );
                },
              ),

              // blur + content — MAKE THIS FILL the given width so internal Row can spaceEvenly
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 18,
                  sigmaY: 18,
                ), // reduced blur
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ), // reduced vertical padding
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.36)
                        : Colors.white.withOpacity(0.58),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      width: 1.0,
                      color: isDark
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white.withOpacity(0.24),
                    ),
                  ),
                  // CRITICAL: use spaceEvenly so three controls are centered exactly
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedIcon(
                        icon: Icons.home_rounded,
                        index: 0,
                        label: 'Home',
                      ),
                      _buildCenterFAB(primary),
                      _buildAnimatedIcon(
                        icon: Icons.person_rounded,
                        index: 2,
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),

              // shimmer sweep (shorter travel distance for reduced width)
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) {
                  return Positioned(
                    left: -100 + (_particleController.value * (width + 200)),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool active = safeIndex == index;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => _setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Container(
                    width: 52 + (_glowController.value * 6),
                    height: 52 + (_glowController.value * 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withOpacity(0.30),
                          primary.withOpacity(0.02),
                        ],
                      ),
                    ),
                  );
                },
              ),
            AnimatedScale(
              scale: active ? 1.02 : 0.94,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 44, // reduced icon container
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active
                      ? LinearGradient(
                          colors: [primary, primary.withOpacity(0.75)],
                        )
                      : null,
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: primary.withOpacity(0.34),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (active)
                      AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(44, 44),
                            painter: _ParticlePainter(
                              progress: _particleController.value,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    Icon(
                      icon,
                      color: active ? Colors.white : Colors.white70,
                      size: 22,
                    ), // reduced icon size
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFAB(Color primary) {
    return GestureDetector(
      onTap: () => _setIndex(1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return Container(
                width: 72 + (_glowController.value * 8),
                height: 72 + (_glowController.value * 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(
                        0.40 + (_glowController.value * 0.08),
                      ),
                      primary.withOpacity(0.0),
                    ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _particleController.value * 2 * math.pi,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        primary.withOpacity(0.6),
                        primary.withOpacity(0.0),
                        primary.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: _activeAnim, curve: Curves.easeOutBack),
            ),
            child: Container(
              width: 60, // reduced FAB size
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.85)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.36),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 30),
              ), // slightly smaller icon
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    const int particleCount = 6;
    for (int i = 0; i < particleCount; i++) {
      final angle =
          (i / particleCount) * 2 * math.pi + (progress * 2 * math.pi);
      final radius = 12 + (progress * 6); // reduced radius
      final particleSize = 2.0 * (1 - progress); // slightly smaller particles
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      paint.color = color.withOpacity(0.9 * (1 - progress));
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
