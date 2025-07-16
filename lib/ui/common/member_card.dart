import 'package:flutter/material.dart';
import '../../model/family_member_model.dart';

class MemberCard extends StatelessWidget {
  final FamilyMember member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    IconData genderIcon = member.gender == 'Female' ? Icons.female : Icons.male;
    Color bgColor =
        member.gender == 'Female' ? Colors.pink.shade100 : Colors.blue.shade100;
    Color borderColor = member.gender == 'Female' ? Colors.pink : Colors.blue;

    String? spouseLabel;
    if (member.spouse != null) {
      if (member.gender == 'Male') {
        spouseLabel = "Husband";
      } else if (member.gender == 'Female') {
        spouseLabel = "Wife";
      }
    }

    return Container(
      width: 130,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            blurStyle: BlurStyle.outer,
            blurRadius: 1,
            color: Colors.grey,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: borderColor.withOpacity(0.3),
            child: Icon(genderIcon, size: 30, color: borderColor),
          ),
          SizedBox(height: 8),
          Text(member.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            member.children.isEmpty ? member.relation : spouseLabel ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
