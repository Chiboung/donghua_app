import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class ItemService {
  ItemService._();
  static final ItemService instance = ItemService._();

  final CollectionReference<Map<String, dynamic>> _items =
      FirebaseFirestore.instance.collection('items');

  /// Items visible to [viewerUid]: every admin-uploaded (public) item,
  /// plus the viewer's own items regardless of visibility. Signed-out
  /// viewers (`viewerUid == null`) see only public items.
  Stream<List<Item>> watchVisibleItems(String? viewerUid) {
    final publicQuery = _items
        .where('uploaderRole', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true);

    if (viewerUid == null) {
      return publicQuery.snapshots().map(
            (snapshot) => snapshot.docs.map(Item.fromFirestore).toList(),
          );
    }

    final ownQuery = _items
        .where('uploaderId', isEqualTo: viewerUid)
        .orderBy('createdAt', descending: true);

    return _mergeById(
      publicQuery.snapshots().map((s) => s.docs.map(Item.fromFirestore)),
      ownQuery.snapshots().map((s) => s.docs.map(Item.fromFirestore)),
    );
  }

  Stream<List<Item>> _mergeById(
    Stream<Iterable<Item>> a,
    Stream<Iterable<Item>> b,
  ) {
    final controller = StreamController<List<Item>>.broadcast();
    List<Item>? latestA;
    List<Item>? latestB;
    StreamSubscription? subA, subB;

    void emit() {
      if (latestA == null || latestB == null) return; // Wait for initial loads

      final mergedMap = <String, Item>{};
      for (final item in latestA!) {
        mergedMap[item.id] = item;
      }
      for (final item in latestB!) {
        mergedMap[item.id] = item;
      }

      final merged = mergedMap.values.toList()
        ..sort((x, y) {
          final dateX = x.updatedAt ?? x.createdAt;
          final dateY = y.updatedAt ?? y.createdAt;
          if (dateX == null || dateY == null) return 0;
          return dateY.compareTo(dateX); // Descending order
        });

      controller.add(merged);
    }

    controller.onListen = () {
      subA = a.listen(
        (items) {
          latestA = items.toList();
          emit();
        },
        onError: controller.addError,
      );
      subB = b.listen(
        (items) {
          latestB = items.toList();
          emit();
        },
        onError: controller.addError,
      );
    };

    controller.onCancel = () async {
      await subA?.cancel();
      await subB?.cancel();
    };

    return controller.stream;
  }

  /// Creates a new item document and returns its generated id.
  Future<String> addItem(Item item) async {
    final doc = await _items.add(item.toFirestore());
    return doc.id;
  }

  Future<void> updateItem(Item item) async {
    await _items.doc(item.id).update(item.toUpdateFirestore());
  }

  Future<void> deleteItem(String itemId) async {
    await _items.doc(itemId).delete();
  }
}
