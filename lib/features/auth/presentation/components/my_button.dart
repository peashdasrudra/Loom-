import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({super.key, required this.onTap, required this.text});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: _isHovering
                  ? [Color(0xFF6C63FF), Color(0xFF00BFFF)]
                  : [Color(0xFF8C82FF), Color(0xFF3ECFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isHovering ? Colors.white : Colors.white70,
                shadows: _isHovering
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
