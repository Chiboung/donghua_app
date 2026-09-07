import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Two account tiers:
/// - [user]: entries they add are private — only they can see them.
/// - [admin]: entries they add are public — visible to every user.
enum UserRole {
  user,
  admin;

  static UserRole fromString(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.user;

  @override
  String toString() => this == UserRole.admin ? 'admin' : 'user';
}

/// Backs the `users/{uid}` Firestore doc that holds each account's
/// [UserRole]. Firebase Auth itself has no concept of roles, so this
/// is the source of truth [ProductService] and the Add screen read
/// from to decide who can see (or publish) what.
///
/// New accounts always start as [UserRole.user] — promoting someone to
/// admin is a deliberate, out-of-band action (edit the Firestore doc
/// in the console, or a secured admin tool), never something the app
/// itself exposes, so a compromised or malicious client can't grant
/// itself elevated access.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Called once per sign-in from [AuthGate]. Creates the `users/{uid}`
  /// doc the first time this account is seen, defaulting to
  /// [UserRole.user]; does nothing on later calls so it never clobbers
  /// a role an admin has since granted.
  Future<void> ensureUserDocument(User user) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    if (snapshot.exists) return;
    await doc.set({
      'email': user.email,
      'displayName': user.displayName,
      'role': UserRole.user.toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// One-off read, used when publishing a new entry so it can be
  /// stamped with the uploader's *current* role.
  Future<UserRole> fetchRole(String uid) async {
    final snapshot = await _users.doc(uid).get();
    return UserRole.fromString(snapshot.data()?['role'] as String?);
  }

  /// Live-updating role for the signed-in user, so the UI (e.g. the
  /// "only visible to you" hint on the Add screen) reacts immediately
  /// if an admin changes their role while they're using the app.
  Stream<UserRole> watchRole(String uid) {
    return _users.doc(uid).snapshots().map(
          (snapshot) => UserRole.fromString(snapshot.data()?['role'] as String?),
        );
  }
}
