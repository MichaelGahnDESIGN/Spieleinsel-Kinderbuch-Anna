// packages/games/memorie/lib/src/memory_card.dart
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum CardState { faceDown, faceUp, matched }

class MemoryCard extends PositionComponent {
  final int index;
  final int pairId;
  CardState state = CardState.faceDown;

  /// Pre-loaded front image. Null → show pair-number fallback.
  final ui.Image? frontImage;

  /// Pre-loaded back image. Null → draw solid colour + dot pattern.
  final ui.Image? backImage;

  final String backColor;

  // Flip animation: 0 = face down, 1 = face up
  double _flipProgress = 0.0;
  double _flipTarget = 0.0;
  static const double _flipSpeed = 4.5; // ~220 ms full flip

  // Match glow animation
  double _matchGlow = 0.0;

  MemoryCard({
    required this.index,
    required this.pairId,
    required Vector2 position,
    required Vector2 cardSize,
    this.frontImage,
    this.backImage,
    this.backColor = '#691b96',
  }) : super(position: position, size: cardSize);

  bool get isFlipped => state == CardState.faceUp || state == CardState.matched;

  void flipUp() {
    if (state == CardState.faceDown) {
      state = CardState.faceUp;
      _flipTarget = 1.0;
    }
  }

  void flipDown() {
    if (state == CardState.faceUp) {
      state = CardState.faceDown;
      _flipTarget = 0.0;
    }
  }

  void markMatched() {
    state = CardState.matched;
    _flipTarget = 1.0;
    _matchGlow = 1.0;
  }

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animate flip
    if (_flipProgress != _flipTarget) {
      if (_flipProgress < _flipTarget) {
        _flipProgress = (_flipProgress + _flipSpeed * dt).clamp(0.0, 1.0);
      } else {
        _flipProgress = (_flipProgress - _flipSpeed * dt).clamp(0.0, 1.0);
      }
    }

    // Fade out match glow
    if (_matchGlow > 0) {
      _matchGlow = (_matchGlow - dt * 1.5).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final radius = math.min(w, h) * 0.08;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(radius),
    );

    // Apply flip transform (scale X to simulate 3D flip)
    final flipAngle = _flipProgress * math.pi;
    final scaleX = math.cos(flipAngle).abs().clamp(0.05, 1.0);
    final showFront = _flipProgress > 0.5;

    canvas.save();
    canvas.translate(w / 2, 0);
    canvas.scale(scaleX, 1.0);
    canvas.translate(-w / 2, 0);

    if (!showFront) {
      // ── Back side ──────────────────────────────────────────────────────────
      if (backImage != null) {
        _drawCoverImage(canvas, backImage!, rrect);
        // Subtle colour overlay to preserve colour identity
        canvas.drawRRect(
          rrect,
          Paint()..color = _hexColor(backColor).withValues(alpha: 0.25),
        );
      } else {
        // Solid colour + dot pattern
        canvas.drawRRect(rrect, Paint()..color = _hexColor(backColor));
        final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
        for (var x = 10.0; x < w; x += 14) {
          for (var y = 10.0; y < h; y += 14) {
            canvas.drawCircle(Offset(x, y), 2, dotPaint);
          }
        }
      }
    } else {
      // ── Front side ─────────────────────────────────────────────────────────
      canvas.drawRRect(rrect, Paint()..color = Colors.white);

      if (frontImage != null) {
        _drawCoverImage(canvas, frontImage!, rrect);
      } else {
        // Fallback: pair number
        final borderPaint = Paint()
          ..color = const Color(0xFF691b96).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rrect, borderPaint);

        final tp = TextPainter(
          text: TextSpan(
            text: pairId.toString(),
            style: const TextStyle(
              color: Color(0xFF691b96),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));
      }

      // Match glow overlay
      if (state == CardState.matched) {
        final glowAlpha = 0.2 + (_matchGlow * 0.3);
        canvas.drawRRect(
          rrect,
          Paint()..color = const Color(0xFF4ecdc4).withValues(alpha: glowAlpha),
        );
      }
    }

    canvas.restore();
  }

  /// Draws [image] filling [clip] with cover-fit (crop to fill, maintain ratio).
  void _drawCoverImage(Canvas canvas, ui.Image image, RRect clip) {
    final dstRect = clip.outerRect;
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    final srcAspect = imgW / imgH;
    final dstAspect = dstRect.width / dstRect.height;

    final Rect srcRect;
    if (srcAspect > dstAspect) {
      // Image wider than card → crop left/right
      final cropW = imgH * dstAspect;
      srcRect = Rect.fromLTWH((imgW - cropW) / 2, 0, cropW, imgH);
    } else {
      // Image taller than card → crop top/bottom
      final cropH = imgW / dstAspect;
      srcRect = Rect.fromLTWH(0, (imgH - cropH) / 2, imgW, cropH);
    }

    canvas.save();
    canvas.clipRRect(clip);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
    canvas.restore();
  }
}
