import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around [FirebaseAuth].
///
/// Keeps Firebase's API (and its exception type) out of the UI layer —
/// screens call these methods and catch [AuthException], which already
/// carries a message that's safe to show a user.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Emits whenever the signed-in user changes (sign in, sign out, or
  /// token refresh on app start). [AuthGate] listens to this to decide
  /// whether to show the login flow or the tabbed shell.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        // Don't let an unverified account into the app. Re-send the
        // verification link while we still have a valid session, then
        // sign back out so AuthGate's StreamBuilder keeps showing the
        // login flow instead of treating this as a successful sign-in.
        String message;
        try {
          await user.sendEmailVerification();
          message =
              'Please verify your email before logging in. We\'ve sent a new verification link to ${user.email ?? email.trim()}.';
        } on FirebaseAuthException catch (e) {
          message = e.code == 'too-many-requests'
              ? 'Please verify your email before logging in. Check your inbox for the link we already sent to ${user.email ?? email.trim()}.'
              : 'Please verify your email before logging in. Check your inbox for the verification link.';
        }
        await _auth.signOut();
        throw AuthEmailNotVerifiedException(message);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        // updateDisplayName doesn't refresh the cached currentUser
        // synchronously, so reload it — screens reading currentUser
        // right after signUp() should see the name immediately.
        await credential.user?.reload();
      }
      await credential.user?.sendEmailVerification();
      // New accounts start out unverified — sign back out so AuthGate
      // keeps showing the login flow until the user confirms their
      // email, instead of dropping them straight into the app.
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  /// Signs in (or, on first use, silently creates the Firebase account
  /// for) the user via their Google account.
  ///
  /// Throws [AuthCancelledException] — a subtype of [AuthException] — if
  /// the user dismisses the Google account picker without choosing one.
  /// Screens should catch that case separately so they don't surface an
  /// error message for a plain cancellation.
  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Picker dismissed — not an error, just no selection made.
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } on AuthCancelledException {
      rethrow;
    } catch (e) {
      // GoogleSignIn itself throws PlatformExceptions (network issues,
      // missing SHA-1/OAuth config, missing Google Play Services, an
      // out-of-date google-services.json, etc.) rather than
      // FirebaseAuthException, so the generic message below can't say
      // *why* it failed. Log the real exception so it shows up in
      // debug console / crash reports — e.g. on Android a PlatformException
      // with code "10" / "sign_in_failed" almost always means the
      // app's SHA-1 (and SHA-256) fingerprint isn't registered for
      // this Firebase project, or google-services.json is stale.
      debugPrint('Google sign-in error: $e');
      throw const AuthException('Google sign-in failed. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  // Future<void> signOut() async {
  //   // Signing out of Firebase alone leaves the Google session active,
  //   // so the account picker gets skipped (and the same account
  //   // silently reused) on the next Google sign-in attempt.
  //   await _googleSignIn.signOut();
  //   await _auth.signOut();
  // }
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out exception (safe to ignore): $e');
    }
    
    // Ensure Firebase Auth sign-out always runs
    await _auth.signOut();
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        // Firebase projects with "email enumeration protection" on
        // (the default for newer projects) deliberately merge "wrong
        // email" and "wrong password" into this one code, so the
        // error can't be used to discover which emails have accounts.
        // Turn that setting off in the Firebase console under
        // Authentication > Settings if you need the split messages
        // above for this case too.
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error — check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// User-facing auth error with a message that's already safe to display.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the user backs out of the Google account picker instead
/// of choosing an account. Not a real error — screens should swallow
/// this quietly rather than showing [message] as an error banner.
class AuthCancelledException extends AuthException {
  const AuthCancelledException() : super('Sign-in cancelled.');
}

/// Thrown by [AuthService.signIn] when the credentials are correct but
/// the account's email hasn't been verified yet. The user is signed
/// back out before this is thrown, so screens can just display
/// [message] like any other [AuthException].
class AuthEmailNotVerifiedException extends AuthException {
  const AuthEmailNotVerifiedException(super.message);
}
