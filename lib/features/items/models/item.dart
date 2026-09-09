import 'package:cloud_firestore/cloud_firestore.dart';

/// A single shop item, backed by a Firestore document in the `items`
/// collection. The photo itself lives on Cloudinary — [imageUrl] is
/// just the secure URL Cloudinary returned after upload.
class Item {
  final String id;
  final String title;
  final String type;
  final double price;

  /// Percentage off [price], 0–100. 0 means no discount.
  final double discount;
  final String description;
  final String imageUrl;
  final String uploaderId;
  final String uploaderName;
  final String uploaderRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.discount,
    required this.description,
    required this.imageUrl,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploaderRole,
    this.createdAt,
    this.updatedAt,
  });

  /// Price after [discount] is applied.
  double get finalPrice => price - (price * discount / 100);

  bool get hasDiscount => discount > 0;

  /// True when this item is public (uploaded by an admin) rather than
  /// private to its uploader.
  bool get isPublic => uploaderRole == 'admin';

  /// Returns a copy of this item with the given fields replaced —
  /// used by the detail screen's edit form to build the version to
  /// save, and to refresh local state after a save succeeds.
  Item copyWith({
    String? title,
    String? type,
    double? price,
    double? discount,
    String? description,
    String? imageUrl,
    String? uploaderRole,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploaderRole: uploaderRole ?? this.uploaderRole,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Item(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      price: ((data['price'] as num?) ?? 0).toDouble(),
      discount: ((data['discount'] as num?) ?? 0).toDouble(),
      description: (data['description'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      uploaderId: (data['uploaderId'] as String?) ?? '',
      uploaderName: (data['uploaderName'] as String?) ?? '',
      uploaderRole: (data['uploaderRole'] as String?) ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map written to Firestore on create. `createdAt` uses the server
  /// clock so listings sort consistently regardless of the uploader's
  /// local time being wrong. `uploaderRole` is snapshotted at write
  /// time — it's what decides whether the item is public or private
  /// to its uploader.
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'type': type,
        'price': price,
        'discount': discount,
        'description': description,
        'imageUrl': imageUrl,
        'uploaderId': uploaderId,
        'uploaderName': uploaderName,
        'uploaderRole': uploaderRole,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Map written to Firestore on edit. Deliberately omits
  /// `createdAt`/`uploaderId`/`uploaderRole` so an edit can never
  /// change when the item was first added or who it belongs to —
  /// `updatedAt` uses the server clock, same reasoning as
  /// `createdAt` in [toFirestore].
  Map<String, dynamic> toUpdateFirestore() => {
        'title': title,
        'type': type,
        'price': price,
        'discount': discount,
        'description': description,
        'imageUrl': imageUrl,
        'uploaderRole': uploaderRole,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
