import '../model/family_member_model.dart';

class MemberService {
  static bool isSpouse(FamilyMember member, FamilyMember root) {
    bool isSpouse = false;

    void search(FamilyMember current) {
      if (current.spouse?.id == member.id) {
        isSpouse = true;
      }
      for (var child in current.children) {
        search(child);
      }
    }

    search(root);
    return isSpouse;
  }

  static void findAndAttachChildToPartner(
    FamilyMember spouse,
    FamilyMember child,
    FamilyMember root,
  ) {
    void attach(FamilyMember current) {
      if (current.spouse?.id == spouse.id) {
        current.children = [...current.children, child];
      }
      for (var c in current.children) {
        attach(c);
      }
    }

    attach(root);
  }

  static bool hasChildAnywhere(FamilyMember member, FamilyMember root) {
    bool found = false;

    void search(FamilyMember current) {
      if (current == member && current.children.isNotEmpty) {
        found = true;
        return;
      }
      if (current.spouse == member && current.children.isNotEmpty) {
        found = true;
        return;
      }

      for (var c in current.children) {
        search(c);
      }
    }

    search(root);
    return found;
  }

  static bool deleteMember(FamilyMember parent, FamilyMember target) {
    final originalLength = parent.children.length;
    parent.children.removeWhere((child) => child.id == target.id);
    if (parent.children.length < originalLength) return true;

    if (parent.spouse?.id == target.id) {
      parent.spouse = null;
      return true;
    }

    for (var child in parent.children) {
      if (child.spouse?.id == target.id) {
        child.spouse = null;
        return true;
      }

      if (deleteMember(child, target)) return true;
    }

    return false;
  }
}
