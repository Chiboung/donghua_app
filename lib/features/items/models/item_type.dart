import 'package:flutter/material.dart';

/// Canonical list of item types, used by the "type" dropdown on
/// [AddItemScreen] and the filter chips on [CategoriesScreen] — kept
/// in one place so a type picked on one screen always has a matching
/// chip on the other.
class ItemType {
  ItemType._();

  static const List<ItemTypeOption> all = [
    ItemTypeOption('Phone', Icons.smartphone_outlined),
    ItemTypeOption('Computer', Icons.desktop_windows_outlined),
    ItemTypeOption('Laptop', Icons.laptop_mac_outlined),
    ItemTypeOption('Tablet', Icons.tablet_mac_outlined),
    ItemTypeOption('Camera', Icons.camera_alt_outlined),
    ItemTypeOption('Accessories', Icons.headphones_outlined),
    // ItemTypeOption('Fashion', Icons.checkroom),
    // ItemTypeOption('Home & Garden', Icons.chair_outlined),
    // ItemTypeOption('Sports', Icons.sports_basketball_outlined),
    // ItemTypeOption('Toys', Icons.toys_outlined),
    // ItemTypeOption('Books', Icons.menu_book_outlined),
    ItemTypeOption('Other', Icons.category_outlined),
  ];

  /// Icon for a given type name; falls back to the "Other" icon for
  /// any legacy/unknown value already stored in Firestore.
  static IconData iconFor(String type) => all
      .firstWhere(
        (t) => t.name == type,
        orElse: () => all.last,
      )
      .icon;
}

class ItemTypeOption {
  final String name;
  final IconData icon;

  const ItemTypeOption(this.name, this.icon);
}
