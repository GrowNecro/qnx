// lib/utils/screenshot.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> captureWidgetAsPng(
  BuildContext context,
  Widget widget, {
  double pixelRatio = 1.2,
  Duration wait = const Duration(milliseconds: 150),
}) async {
  final completer = Completer<Uint8List>();
  final key = GlobalKey();

  final overlay = Overlay.of(context);
  if (overlay == null) {
    throw Exception('No Overlay found in context (need MaterialApp/Overlay).');
  }

  final entry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.transparent,
      child: Offstage(
        offstage: false, // <- make sure widget actually gets layout & paint
        child: RepaintBoundary(
          key: key,
          child: SizedBox.expand(child: widget),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // Ensure at least one frame and allow async elements to settle
  await WidgetsBinding.instance.endOfFrame;
  if (wait > Duration.zero) await Future.delayed(wait);

  try {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject == null) throw Exception('RenderObject not found.');
    if (renderObject is! RenderRepaintBoundary) {
      throw Exception(
        'Expected RenderRepaintBoundary but got ${renderObject.runtimeType}.',
      );
    }

    final boundary = renderObject as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('Failed to convert image to bytes.');

    final bytes = byteData.buffer.asUint8List();
    completer.complete(bytes);
  } catch (e) {
    completer.completeError(e);
  } finally {
    entry.remove();
  }

  return completer.future;
}
