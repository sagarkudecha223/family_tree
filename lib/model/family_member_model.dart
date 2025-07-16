class FamilyMember {
  final String id;
  String name;
  String relation;
  String? gender;
  FamilyMember? spouse;
  List<FamilyMember> children;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.gender,
    this.spouse,
    this.children = const [],
  });

  static FamilyMember fromJson(Map<String, dynamic> json) {
    final member = FamilyMember(
      id: json['id'],
      name: json['name'],
      relation: json['relation'],
      gender: json['gender'],
      children: [],
    );

    if (json['spouse'] != null) {
      member.spouse = fromJson(json['spouse']);
    }

    if (json['children'] != null) {
      member.children =
          (json['children'] as List)
              .map((childJson) => fromJson(childJson))
              .toList();
    }

    return member;
  }
}
