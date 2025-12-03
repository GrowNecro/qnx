import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable menu button widget with consistent styling
class MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final bool enabled;
  final IconData? icon;

  const MenuButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 120,
    this.fontSize = 36,
    this.backgroundColor = const Color(0xB3FFFFFF), // white with 0.7 alpha
    this.textColor = Colors.black,
    this.enabled = true,
    this.icon,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? screenWidth * 0.9,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onPressed?.call();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.textColor, size: 28),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.enabled ? widget.textColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
