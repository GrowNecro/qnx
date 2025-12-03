import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global settings manager with caching
class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  double brightness = 1.0;
  double volume = 0.5;

  // Callbacks for settings changes
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void setBrightness(double value) {
    brightness = value.clamp(0.2, 1.0);
    _notifyListeners();
  }

  void setVolume(double value) {
    volume = value.clamp(0.0, 1.0);
    _notifyListeners();
  }
}

/// Brightness overlay widget that can be used globally
class BrightnessOverlay extends StatelessWidget {
  final double brightness;
  final Widget child;

  const BrightnessOverlay({
    super.key,
    required this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (brightness < 1.0)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 1.0 - brightness),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension for easy haptic feedback
extension HapticFeedbackExtension on Widget {
  Widget withHapticFeedback({
    HapticFeedbackType type = HapticFeedbackType.medium,
  }) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticFeedbackType.light:
            HapticFeedback.lightImpact();
          case HapticFeedbackType.medium:
            HapticFeedback.mediumImpact();
          case HapticFeedbackType.heavy:
            HapticFeedback.heavyImpact();
          case HapticFeedbackType.selection:
            HapticFeedback.selectionClick();
        }
      },
      child: this,
    );
  }
}

enum HapticFeedbackType { light, medium, heavy, selection }

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 3,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  @override
  void initState() {
    super.initState();
  }

  void _reset() {
    setState(() {
      _error = null;
      _stack = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stack) ??
          _defaultErrorWidget(_error!, _stack);
    }

    return widget.child;
  }

  Widget _defaultErrorWidget(Object error, StackTrace? stack) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
