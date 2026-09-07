import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final CollectionReference<Map<String, dynamic>> _products =
      FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> watchVisibleProducts(String? viewerUid) {
    final publicQuery = _products
        .where('uploaderRole', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true);

    if (viewerUid == null) {
      return publicQuery.snapshots().map(
            (snapshot) => snapshot.docs.map(Product.fromFirestore).toList(),
          );
    }

    // Firestore string parameters must be valid field names.
    // We order by 'createdAt' to keep query indexes consistent with publicQuery.
    final ownQuery = _products
        .where('uploaderId', isEqualTo: viewerUid)
        .orderBy('createdAt', descending: true);

    return _mergeById(
      publicQuery.snapshots().map((s) => s.docs.map(Product.fromFirestore)),
      ownQuery.snapshots().map((s) => s.docs.map(Product.fromFirestore)),
    );
  }

  Stream<List<Product>> _mergeById(
    Stream<Iterable<Product>> a,
    Stream<Iterable<Product>> b,
  ) {
    final controller = StreamController<List<Product>>.broadcast();
    List<Product>? latestA;
    List<Product>? latestB;
    StreamSubscription? subA, subB;

    void emit() {
      if (latestA == null || latestB == null) return; // Wait for initial loads

      final mergedMap = <String, Product>{};
      for (final p in latestA!) {
        mergedMap[p.id] = p;
      }
      for (final p in latestB!) {
        mergedMap[p.id] = p;
      }

      final merged = mergedMap.values.toList()
        ..sort((x, y) {
          // Fallback to createdAt if updatedAt is null
          final dateX = x.updatedAt ?? x.createdAt;
          final dateY = y.updatedAt ?? y.createdAt;

          if (dateX == null || dateY == null) return 0;
          return dateY.compareTo(dateX); // Descending order
        });

      controller.add(merged);
    }

    controller.onListen = () {
      subA = a.listen(
        (products) {
          latestA = products.toList();
          emit();
        },
        onError: controller.addError,
      );
      subB = b.listen(
        (products) {
          latestB = products.toList();
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

  /// Creates a new entry document and returns its generated id.
  Future<String> addProduct(Product product) async {
    final doc = await _products.add(product.toFirestore());
    return doc.id;
  }

  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toUpdateFirestore());
  }
}