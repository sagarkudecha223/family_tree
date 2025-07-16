import 'dart:math';
import 'dart:ui';

import '../model/family_member_model.dart';
import '../model/position_member_model.dart';

class TreeBuilder {
  static List<PositionedMember> layoutTree(
    FamilyMember root,
    double startX,
    double startY,
  ) {
    List<PositionedMember> result = [];
    double nodeWidth = 140;
    double xSpacing = 60;
    double ySpacing = 200;

    double layout(FamilyMember member, double x, double y) {
      double currentX = x;
      double maxX = x;
      double midX;

      final spouseWidth = member.spouse != null ? nodeWidth : 0;
      final coupleCenterX = currentX + (nodeWidth + spouseWidth) / 2;

      if (member.children.length == 1) {
        // Special case: One child → center under couple
        final child = member.children.first;
        final childX = coupleCenterX + 10;
        maxX = layout(child, childX, y + ySpacing);
        midX = coupleCenterX - nodeWidth / 2;
      } else if (member.children.isNotEmpty) {
        List<double> childXs = [];

        for (var child in member.children) {
          maxX = layout(child, maxX, y + ySpacing);
          childXs.add(maxX);
          maxX += nodeWidth + xSpacing;
        }

        midX = (childXs.first + childXs.last) / 2 - nodeWidth / 2;
      } else {
        midX = currentX;
      }

      // Add primary member
      result.add(PositionedMember(member: member, position: Offset(midX, y)));

      // Add spouse if any
      if (member.spouse != null) {
        double spouseSpacing = 20;
        result.add(
          PositionedMember(
            member: member.spouse!,
            position: Offset(midX + nodeWidth + spouseSpacing, y),
          ),
        );
      }
      return max(
        midX + nodeWidth + (member.spouse != null ? nodeWidth : 0),
        maxX,
      );
    }

    layout(root, startX, startY);
    return result;
  }
}
