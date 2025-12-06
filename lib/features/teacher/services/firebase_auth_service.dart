import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'class_teacher_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  User? get currentUser => _currentUser;

  FirebaseAuthService(FirebaseAuth? auth)
    : _auth = auth ?? FirebaseAuth.instance;

  Future<UserCredential> createUser({
    required String username,
    required String email,
    required String password,
    required String photoUrl,
  }) async {
    try {
      // Buat akun di Firebase Authentication
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update nama tampilan
      await result.user!.updateDisplayName(username);

      // Simpan data tambahan user ke Firestore
      await _firestore.collection('teachers').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'username': username,
        'email': email,
        'photoUrl': photoUrl,
      });
      return result;
    } on FirebaseAuthException catch (e) {
      final errorMessage = switch (e.code) {
        "email-already-in-use" =>
          "Email sudah digunakan, silahkan gunakan Email lain!",
        "invalid-email" => "Email ini tidak falid!!!",
        "operation-not-allowed" =>
          "Server error, Periksa jaringan anda atau coba lagi nanti.",
        "weak-password" => "Kata Sandimu terlalu lemah",
        _ => "Pendaftaran Gagal. Coba lagi!.",
      };
      throw errorMessage;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UserCredential> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Format email tidak valid.";
          break;
        case "user-disabled":
          errorMessage = "Akun ini telah dinonaktifkan oleh admin.";
          break;
        case "user-not-found":
          errorMessage =
              "Akun tidak ditemukan. Pastikan email sudah terdaftar.";
          break;
        case "wrong-password":
          errorMessage = "Kata sandi salah. Silakan coba lagi.";
          break;
        case "invalid-credential":
          errorMessage = "Email atau kata sandi salah.";
          break;
        case "too-many-requests":
          errorMessage =
              "Terlalu banyak percobaan login. Coba beberapa saat lagi.";
          break;
        case "network-request-failed":
          errorMessage = "Koneksi internet bermasalah. Periksa jaringan Anda.";
          break;
        default:
          errorMessage = "Terjadi kesalahan saat login (${e.code}).";
      }

      throw errorMessage;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user canceled sign-in
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      _currentUser = userCredential.user;

      debugPrint(
        "Google Sign-In Success with UID: ${userCredential.user?.uid}",
      );
      if (userCredential.user != null) {
        await ClassTeacherService().setUser(
          userCredential.user!.uid,
          userCredential.user?.displayName,
          userCredential.user!.email!,
          photoUrl: userCredential.user?.photoURL,
        );
      }
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception("Logout failed. Please try again.");
    }
  }

  //  memeriksa user yang telah melakukan login. Fungsi ini bertugas untuk mendapatkan data pengguna yang berhasil melakukan login.
  Stream<User?> userChanges() {
    return _auth.userChanges();
  }
}
