import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Register dengan Email & Password
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email sudah terdaftar.';
      } else if (e.code == 'invalid-email') {
        throw 'Format email tidak valid.';
      }
      throw e.message ?? 'Terjadi kesalahan saat mendaftar.';
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Login dengan Email & Password
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password') {
        throw 'Password salah.';
      } else if (e.code == 'invalid-credential') {
        throw 'Email atau password tidak valid.';
      } else if (e.code == 'invalid-email') {
        throw 'Format email tidak valid.';
      } else if (e.code == 'user-disabled') {
        throw 'Akun telah dinonaktifkan.';
      } else if (e.code == 'too-many-requests') {
        throw 'Terlalu banyak percobaan login. Coba lagi nanti.';
      } else if (e.code == 'network-request-failed') {
        throw 'Tidak ada koneksi internet.';
      } else if (e.code == 'operation-not-allowed') {
        throw 'Login dengan email/password tidak diizinkan.';
      }
      throw e.message ?? 'Terjadi kesalahan saat login.';
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Login dengan Google
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw 'Gagal login dengan Google: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Gagal logout: $e';
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Email tidak terdaftar.';
      }
      throw e.message ?? 'Gagal mengirim email reset password.';
    } catch (e) {
      throw 'Terjadi kesalahan: $e';
    }
  }
}
