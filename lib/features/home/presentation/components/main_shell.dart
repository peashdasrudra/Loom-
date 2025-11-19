// lib/features/core/main_shell.dart
// Professional, minimal, deploy-ready MainShell
// - Subtle frosted glass bottom nav
// - Responsive, centered, narrow max width
// - Minimal animations: nav show/hide + small active/pulse animations
// - Easy-to-tune constants at top

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainShell extends StatefulWidget {
  final List<Widget> pages;
  final Widget? drawer;

  const MainShell({super.key, required this.pages, this.drawer});

  /// Pages can reserve this much bottom padding to avoid overlap with the nav.
  /// Set to ~90 for a compact nav (change if you alter sizes below).
  static const double navBaseHeight = 90.0;

  /// Global scaffold key so pages can open the drawer reliably.
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  // ----- Configuration constants (tweak these for different looks) -----
  static const double _navMaxWidth = 520.0;
  static const double _navScreenFraction = 0.84; // fraction of screen width
  static const double _navVerticalPadding = 10.0;
  static const double _blurSigma = 3.0; // subtle glass blur
  static const double _glowOpacityBase = 0.08;
  static const double _glowBlurBase = 20.0;
  static const double _iconContainerSize = 38.0;
  static const double _iconSize = 20.0;
  static const double _fabSize = 56.0;
  static const Duration _navAnimDur = Duration(milliseconds: 300);
  static const Duration _activeAnimDur = Duration(milliseconds: 260);
  // --------------------------------------------------------------------

  int _index = 0;
  late final AnimationController _navController; // show/hide nav
  late final AnimationController _activeController; // micro animation on tap
  late final AnimationController _fabPulseController; // subtle FAB pulse

  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();

    _navController = AnimationController(
      vsync: this,
      duration: _navAnimDur,
      value: 1.0,
    );

    _activeController = AnimationController(
      vsync: this,
      duration: _activeAnimDur,
    )..value = 1.0;

    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _navController.dispose();
    _activeController.dispose();
    _fabPulseController.dispose();
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

  void _updateNavVisibility(BuildContext context) {
    final shouldHide = _drawerOpen || _keyboardOpen(context);
    if (shouldHide) {
      _navController.reverse();
    } else {
      _navController.forward();
      // play a small active micro-bounce so the bar feels alive after re-appearing
      _activeController
          .forward(from: 0.0)
          .then((_) => _activeController.reverse());
    }
  }

  // Called by pages if they open/close the drawer manually.
  void notifyDrawerState(bool open) {
    _drawerOpen = open;
    _updateNavVisibility(context);
  }

  void _setIndex(int idx) {
    if (idx == safeIndex) {
      HapticFeedback.selectionClick();
      _activeController
          .forward(from: 0.0)
          .then((_) => _activeController.reverse());
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _index = idx);
    _activeController
        .forward(from: 0.0)
        .then((_) => _activeController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    // react to keyboard changes
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateNavVisibility(context),
    );

    return Scaffold(
      key: MainShell.scaffoldKey,
      drawer: widget.drawer,
      extendBody: true, // let the nav sit above the scaffold body
      onDrawerChanged: (isOpen) {
        _drawerOpen = isOpen;
        _updateNavVisibility(context);
      },
      body: Stack(
        children: [
          // main pages with smooth cross-fade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(safeIndex),
              child: widget.pages.isNotEmpty
                  ? widget.pages[safeIndex]
                  : const SizedBox.shrink(),
            ),
          ),

          // Bottom navigation overlay
          AnimatedBuilder(
            animation: _navController,
            builder: (context, _) {
              final t = _navController.value; // 0..1
              final bottom = lerpDouble(-120, 12, t)!; // slide up when visible
              return Positioned(
                left: 0,
                right: 0,
                bottom: bottom,
                child: Opacity(
                  opacity: t,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final navWidth = math.min(
                          maxWidth * _navScreenFraction,
                          _navMaxWidth,
                        );
                        return SizedBox(
                          width: navWidth,
                          child: _navBar(context, navWidth),
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

  // Build the nav bar's visual container and content.
  Widget _navBar(BuildContext context, double width) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // subtle background glow (low cost visual depth)
        Container(
          width: math.min(width, 420),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(_glowOpacityBase),
                blurRadius: _glowBlurBase,
                spreadRadius: 1.0,
              ),
            ],
          ),
        ),

        // frosted glass + content
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: _navVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.26)
                    : Colors.white.withOpacity(0.46),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  width: 1.0,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon(
                    icon: Icons.home_rounded,
                    index: 0,
                    primary: primary,
                  ),
                  _centerFAB(primary),
                  _navIcon(
                    icon: Icons.person_rounded,
                    index: 2,
                    primary: primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Clean nav icon used for Home/Profile
  Widget _navIcon({
    required IconData icon,
    required int index,
    required Color primary,
  }) {
    final bool active = safeIndex == index;

    return GestureDetector(
      onTap: () => _setIndex(index),
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_activeController, _fabPulseController]),
        builder: (context, _) {
          // subtle scale when active or on interaction
          final scale = active
              ? (1.0 + (_activeController.value * 0.02))
              : (0.94 + 0.06 * _activeController.value);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: _iconContainerSize,
              height: _iconContainerSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active
                    ? LinearGradient(
                        colors: [primary, primary.withOpacity(0.85)],
                      )
                    : null,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: _iconSize,
                color: active ? Colors.white : Colors.white.withOpacity(0.88),
              ),
            ),
          );
        },
      ),
    );
  }

  // Center FAB: compact, slightly pulsing to attract attention without shouting.
  Widget _centerFAB(Color primary) {
    return GestureDetector(
      onTap: () => _setIndex(1),
      child: AnimatedBuilder(
        animation: _fabPulseController,
        builder: (context, _) {
          final pulse = 1.0 + (_fabPulseController.value * 0.03); // small pulse
          return Transform.scale(
            scale: pulse,
            child: Container(
              width: _fabSize,
              height: _fabSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.9)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 26),
              ),
            ),
          );
        },
      ),
    );
  }
}
