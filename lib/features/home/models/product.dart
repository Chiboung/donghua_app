import 'package:cloud_firestore/cloud_firestore.dart';

/// A single donghua/anime listing, backed by a Firestore document in
/// the `products` collection. The cover image itself lives on
/// Cloudinary — [imageUrl] is just the secure URL Cloudinary returned
/// after upload.
class Product {
  final String id;
  final String titleEn;
  final String titleKh;
  final int season;
  final int episode;
  final int totalEpisodes;
  final String description;
  final String imageUrl;
  final String uploaderId;
  final String uploaderName;
  final String uploaderRole;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.titleEn,
    required this.titleKh,
    required this.season,
    required this.episode,
    required this.totalEpisodes,
    required this.description,
    required this.imageUrl,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploaderRole,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns a copy of this entry with the given fields replaced —
  /// used by the edit screen to build the version to save, and to
  /// refresh local state after a save succeeds.
  Product copyWith({
    String? titleEn,
    String? titleKh,
    int? season,
    int? episode,
    int? totalEpisodes,
    String? description,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id,
      titleEn: titleEn ?? this.titleEn,
      titleKh: titleKh ?? this.titleKh,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploaderRole: uploaderRole,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// True when this entry is public (uploaded by an admin) rather than
  /// private to its uploader.
  bool get isPublic => uploaderRole == 'admin';

  /// e.g. "Season 3 · Ep 12 / 24"
  //String get episodeLabel => 'Season $season · Ep $episode / $totalEpisodes';

  String get episodeLabel => 'Ep $episode / $totalEpisodes · $description';

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Product(
      id: doc.id,
      titleEn: (data['titleEn'] as String?) ?? '',
      titleKh: (data['titleKh'] as String?) ?? '',
      season: ((data['season'] as num?) ?? 0).toInt(),
      episode: ((data['episode'] as num?) ?? 0).toInt(),
      totalEpisodes: ((data['totalEpisodes'] as num?) ?? 0).toInt(),
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
  /// clock (not the device's) so listings sort consistently regardless
  /// of an uploader's local time being wrong. `uploaderRole` is
  /// snapshotted at write time — it's what [ProductService] filters on
  /// to decide whether an entry is public or private to its uploader.
  Map<String, dynamic> toFirestore() => {
        'titleEn': titleEn,
        'titleKh': titleKh,
        'season': season,
        'episode': episode,
        'totalEpisodes': totalEpisodes,
        'description': description,
        'imageUrl': imageUrl,
        'uploaderId': uploaderId,
        'uploaderName': uploaderName,
        'uploaderRole': uploaderRole,
        'createdAt': FieldValue.serverTimestamp(),
      };

  /// Map written to Firestore on edit. Deliberately omits
  /// `createdAt`/`uploaderId`/`uploaderRole` so an edit can never
  /// change when the entry was first added or who it belongs to —
  /// `updatedAt` uses the server clock, same reasoning as
  /// `createdAt` in [toFirestore].
  Map<String, dynamic> toUpdateFirestore() => {
        'titleEn': titleEn,
        'titleKh': titleKh,
        'season': season,
        'episode': episode,
        'totalEpisodes': totalEpisodes,
        'description': description,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
