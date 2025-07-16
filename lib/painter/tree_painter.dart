import 'dart:math';

import 'package:flutter/material.dart';

import '../model/position_member_model.dart';

class TreeLinePainter extends CustomPainter {
  final List<PositionedMember> members;

  TreeLinePainter(this.members);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 2;

    final memberMap = {for (var m in members) m.member.id: m.position};
    final drawnParentIds = <String>{};

    for (var pm in members) {
      final parent = pm.member;

      // Skip if already handled
      if (drawnParentIds.contains(parent.id)) continue;

      final parentOffset = pm.position;

      if (parent.spouse != null) {
        final spouse = parent.spouse!;
        if (!memberMap.containsKey(spouse.id)) continue;

        final spouseOffset = memberMap[spouse.id]!;
        final topY = parentOffset.dy + 60;
        final p1X = parentOffset.dx + 65;
        final p2X = spouseOffset.dx + 65;
        final centerX = (p1X + p2X) / 2;

        // Draw horizontal line between spouses
        canvas.drawLine(Offset(p1X, topY), Offset(p2X, topY), paint);

        if (parent.children.isNotEmpty) {
          final vLineStart = Offset(centerX, topY);
          final vLineEnd = Offset(centerX, topY + 100);

          // Draw vertical line down from couple to child connector
          canvas.drawLine(vLineStart, vLineEnd, paint);

          final hY = vLineEnd.dy;

          if (parent.children.length == 1) {
            // --- ONE CHILD ---
            final child = parent.children.first;
            if (memberMap.containsKey(child.id)) {
              final childOffset = memberMap[child.id]!;
              final childTopY = childOffset.dy;

              // Vertical line from couple center to child top
              canvas.drawLine(
                Offset(centerX, hY),
                Offset(centerX, childTopY),
                paint,
              );
            }
          } else if (parent.children.length == 2) {
            // --- TWO CHILDREN ---
            final childOffsets =
            parent.children
                .where((c) => memberMap.containsKey(c.id))
                .map((c) => memberMap[c.id]!.dx + 65)
                .toList();

            if (childOffsets.length == 2) {
              final leftX = childOffsets[0];
              final rightX = childOffsets[1];
              final midX = (leftX + rightX) / 2;

              // Horizontal connector line between two children
              canvas.drawLine(Offset(leftX, hY), Offset(rightX, hY), paint);

              // Vertical line from couple to midpoint of horizontal
              canvas.drawLine(
                Offset(centerX, vLineEnd.dy),
                Offset(midX, hY),
                paint,
              );

              // Lines to each child
              for (var c in parent.children) {
                if (!memberMap.containsKey(c.id)) continue;
                final childOffset = memberMap[c.id]!;
                final cx = childOffset.dx + 65;
                final cy = childOffset.dy;
                canvas.drawLine(Offset(cx, hY), Offset(cx, cy), paint);
              }
            }
          } else {
            // --- 3+ CHILDREN ---
            final childXs =
            parent.children
                .where((c) => memberMap.containsKey(c.id))
                .map((c) => memberMap[c.id]!.dx + 65)
                .toList();

            if (childXs.isNotEmpty) {
              final minX = childXs.reduce(min);
              final maxX = childXs.reduce(max);

              // Horizontal line across all children
              canvas.drawLine(Offset(minX, hY), Offset(maxX, hY), paint);

              // Vertical from couple to center of child line
              final midX = (minX + maxX) / 2;
              canvas.drawLine(
                Offset(centerX, vLineEnd.dy),
                Offset(midX, hY),
                paint,
              );

              // Vertical down to each child
              for (var c in parent.children) {
                if (!memberMap.containsKey(c.id)) continue;
                final childOffset = memberMap[c.id]!;
                final cx = childOffset.dx + 65;
                final cy = childOffset.dy;
                canvas.drawLine(Offset(cx, hY), Offset(cx, cy), paint);
              }
            }
          }
        }

        // Mark both parents as drawn
        drawnParentIds.add(parent.id);
        drawnParentIds.add(spouse.id);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
