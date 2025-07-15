import 'package:family_tree/ui/member_view.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

import '../model/family_member.dart';
import 'add_member_screen.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  final Graph graph = Graph()..isTree = false;
  final BuchheimWalkerConfiguration _builder = BuchheimWalkerConfiguration();

  final Map<int, FamilyMember> members = {};
  int _nextId = 1;

  int? parentsConnectorId;
  int? fatherId;
  int? motherId;

  @override
  void initState() {
    super.initState();
    _addInitialMembers();
    _builder
      ..siblingSeparation = (50)
      ..levelSeparation = (70)
      ..subtreeSeparation = (50)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  void _addInitialMembers() {
    fatherId = _addMember("Daniel", "Father", null);
    motherId = _addMember("Lorna", "Mother", null);

    parentsConnectorId = _nextId++;
    graph.addNode(Node.Id(parentsConnectorId));

    graph.addEdge(Node.Id(fatherId), Node.Id(parentsConnectorId));
    graph.addEdge(Node.Id(motherId), Node.Id(parentsConnectorId));

    _addMember("Sebastian", "Brother", parentsConnectorId);
    _addMember("Korina", "Sister", parentsConnectorId);
    _addMember("Shawn", "Brother", parentsConnectorId);
    _addMember("Helene", "Sister in law", 3);
  }

  int _addMember(String name, String role, int? parentId) {
    final newId = _nextId++;
    final newMember = FamilyMember(id: newId, name: name, role: role);
    final newNode = Node.Id(newId);

    members[newId] = newMember;
    if (!graph.nodes.contains(newNode)) {
      graph.addNode(newNode);
    }
    if (parentId != null) {
      graph.addEdge(Node.Id(parentId), newNode);
    }
    return newId;
  }

  Widget _getNodeText(int id) {
    if (!members.containsKey(id)) {
      return SizedBox.shrink();
    }
    final member = members[id]!;
    return InkWell(
      onTap: () => _editMember(member),
      child: MemberView(member: member),
    );
  }

  void _editMember(FamilyMember member) {
    TextEditingController nameController = TextEditingController(
      text: member.name,
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Edit Member"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => member.name = nameController.text);
                  Navigator.pop(ctx);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _navigateToAddMemberScreen() => Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => AddMemberScreen(
            members: members,
            onAdd:
                (name, role, parentId) =>
                    setState(() => _addMember(name, role, parentId)),
          ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Family Tree")),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMemberScreen,
        child: Icon(Icons.add),
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.01,
        maxScale: 5.0,
        child: GraphView(
          graph: graph,
          algorithm: BuchheimWalkerAlgorithm(
            _builder,
            TreeEdgeRenderer(_builder),
          ),
          builder: (Node node) => _getNodeText(node.key!.value as int),
        ),
      ),
    );
  }
}
