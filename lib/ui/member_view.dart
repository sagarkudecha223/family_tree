import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../model/family_member.dart';

class MemberView extends StatelessWidget {
  final FamilyMember member;

  const MemberView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 25, child: Icon(Icons.person, size: 30)),
        Gap(6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                member.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(member.role, style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}
