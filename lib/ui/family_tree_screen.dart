import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../controller/tree_builder.dart';
import '../model/family_member_model.dart';
import '../model/position_member_model.dart';
import '../painter/tree_painter.dart';
import '../service/member_service.dart';
import 'add_member_screen.dart';
import 'common/member_card.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  late FamilyMember root;

  @override
  void initState() {
    super.initState();
    root = FamilyMember(
      id: '1',
      name: 'Daniel',
      relation: 'Father',
      gender: 'Male',
      children: [],
    );
    final lorna = FamilyMember(
      id: '2',
      name: 'Lorna',
      gender: 'Female',
      relation: 'Mother',
    );
    root.spouse = lorna;
  }

  Size _calculateCanvasSize(List<PositionedMember> members) {
    if (members.isEmpty) return Size(500, 500);
    double maxX = members.map((m) => m.position.dx).reduce(max) + 200;
    double maxY = members.map((m) => m.position.dy).reduce(max) + 200;
    return Size(maxX, maxY);
  }

  void _navigateToAddScreen(FamilyMember member, String relation) async {
    final newMember = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddMemberScreen(relation: relation)),
    );

    if (newMember != null && newMember is FamilyMember) {
      setState(() {
        if (relation == 'Spouse') {
          member.spouse = newMember;
        } else if (relation == 'Child') {
          if (MemberService.isSpouse(member, root)) {
            MemberService.findAndAttachChildToPartner(member, newMember, root);
          } else {
            member.children = [...member.children, newMember];
          }
        }
      });
    }
  }

  void _showJsonInputDialog() {
    TextEditingController jsonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Paste Family Tree JSON"),
            content: TextField(
              controller: jsonController,
              maxLines: 10,
              decoration: InputDecoration(hintText: "Paste JSON here..."),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    final jsonData = jsonDecode(jsonController.text);
                    final newRoot = FamilyMember.fromJson(jsonData);

                    setState(() => root = newRoot);
                    Navigator.pop(context);
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Invalid JSON: $e")));
                  }
                },
                child: Text("Import"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = TreeBuilder.layoutTree(root, 100, 50);

    return Scaffold(
      appBar: AppBar(title: Text('Family Tree')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showJsonInputDialog,
        child: Icon(Icons.upload_file),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 2.5,
        child: Stack(
          children: [
            CustomPaint(
              size: _calculateCanvasSize(members),
              painter: TreeLinePainter(members),
            ),
            ...members.map(
              (pm) => Positioned(
                left: pm.position.dx,
                top: pm.position.dy,
                child: InkWell(
                  onTap: () => _showMemberOptions(pm.member),
                  child: MemberCard(member: pm.member),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(FamilyMember member) {
    bool isSpouse = MemberService.isSpouse(member, root);
    bool hasSpouse = member.spouse != null || isSpouse;
    bool isChildless = member.children.isEmpty;

    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSpouse && member.spouse == null)
                ListTile(
                  title: Text("Add Spouse"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddScreen(member, 'Spouse');
                  },
                ),
              if (hasSpouse)
                ListTile(
                  title: Text("Add Child"),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddScreen(member, 'Child');
                  },
                ),
              ListTile(
                title: Text("Edit Member"),
                onTap: () {
                  Navigator.pop(context);
                  _editMember(member);
                },
              ),
              if (isChildless && !MemberService.hasChildAnywhere(member, root))
                ListTile(
                  title: Text("Delete Member"),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteMember(member);
                  },
                ),
            ],
          ),
    );
  }

  void _editMember(FamilyMember member) async {
    final updatedMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddMemberScreen(
              relation: member.relation,
              existingMember: member,
            ),
      ),
    );

    if (updatedMember != null && updatedMember is FamilyMember) {
      setState(() {
        member.name = updatedMember.name;
        member.gender = updatedMember.gender;
      });
    }
  }

  void _confirmDeleteMember(FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Delete ${member.name}?"),
            content: Text("Are you sure you want to delete this member?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  MemberService.deleteMember(root, member);
                  setState(() {});
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
