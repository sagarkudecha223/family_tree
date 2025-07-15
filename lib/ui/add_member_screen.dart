import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../model/family_member.dart';

class AddMemberScreen extends StatefulWidget {
  final Map<int, FamilyMember> members;
  final Function(String name, String role, int? parentId) onAdd;

  const AddMemberScreen({
    super.key,
    required this.members,
    required this.onAdd,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final nameController = TextEditingController();
  String selectedRole = 'Child';
  int? selectedParentId;

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      selectedParentId = widget.members.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Member")),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            Gap(16),
            Text("Select Relationship Role", style: TextStyle(fontWeight: FontWeight.bold)),
            Gap(4),
            DropdownButton<String>(
              value: selectedRole,
              items: ['Father', 'Mother', 'Child', 'Sibling']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (val) => setState(() => selectedRole = val!),
            ),
            Gap(16),
            Text("Select Related Parent/Sibling", style: TextStyle(fontWeight: FontWeight.bold)),
            Gap(4),
            DropdownButton<int>(
              value: selectedParentId,
              items: widget.members.entries
                  .map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value.name),
              ))
                  .toList(),
              onChanged: (val) => setState(() => selectedParentId = val!),
            ),
            Gap(32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty || selectedParentId == null) return;

                  final isDuplicate = widget.members.values.any((m) => m.name == name);
                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Member with name already exists')),
                    );
                    return;
                  }

                  int? actualParentId;

                  if (selectedRole == 'Child') {
                    actualParentId = selectedParentId;
                  } else if (selectedRole == 'Sibling') {
                    final selected = widget.members[selectedParentId];
                    if (selected != null) {
                      // Use parent's ID if available (you can enhance this logic later)
                      actualParentId = selectedParentId; // Simplified for now
                    }
                  } else {
                    actualParentId = null; // Father/Mother go to top level
                  }

                  widget.onAdd(name, selectedRole, actualParentId);
                  Navigator.pop(context);
                },
                child: Text('Add Member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
