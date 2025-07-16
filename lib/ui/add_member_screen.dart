import 'package:flutter/material.dart';

import '../model/family_member_model.dart';

class AddMemberScreen extends StatefulWidget {
  final String relation;

  final FamilyMember? existingMember;

  const AddMemberScreen({
    super.key,
    required this.relation,
    this.existingMember,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final nameController = TextEditingController();
  String selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    if (widget.existingMember != null) {
      nameController.text = widget.existingMember!.name;
      selectedGender = widget.existingMember!.gender ?? 'Male';
    }
  }

  void _submit() {
    if (nameController.text.isEmpty) return;

    final updated = FamilyMember(
      id:
          widget.existingMember?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text,
      relation: widget.relation,
      gender: selectedGender,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add ${widget.relation}")),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Gender: "),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedGender,
                  hint: Text("Select"),
                  items:
                      ['Male', 'Female'].map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _submit, child: Text('Add')),
          ],
        ),
      ),
    );
  }
}
