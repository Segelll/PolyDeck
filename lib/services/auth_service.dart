import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
  ],
);
  Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      if (kDebugMode) {
        print("Google Sign-In iptal edildi");
      }
      return null;
    }

    if (kDebugMode) {
      print('Google Kullanıcısı Bulundu: ${googleUser.email}');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    if (kDebugMode) {
      print('Google Kimlik Bilgileri Alındı');
    }
    if (kDebugMode) {
      print('Access Token: ${googleAuth.accessToken}');
    }
    if (kDebugMode) {
      print('ID Token: ${googleAuth.idToken}');
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    if (kDebugMode) {
      print('Firebase Kimlik Bilgileri Oluşturuldu');
    }

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    
    if (kDebugMode) {
      print('Firebase Girişi Başarılı: ${authResult.user?.email}');
    }

    return authResult.user;
  } catch (error) {
    if (kDebugMode) {
      print('Google Sign-In Hatası: $error');
    }
    
    if (error is FirebaseAuthException) {
      if (kDebugMode) {
        print('Firebase Auth Hatası Kodu: ${error.code}');
      }
      if (kDebugMode) {
        print('Hata Mesajı: ${error.message}');
      }
    } else if (error is PlatformException) {
      if (kDebugMode) {
        print('Platform Hatası Kodu: ${error.code}');
      }
      if (kDebugMode) {
        print('Platform Hata Mesajı: ${error.message}');
      }
      if (kDebugMode) {
        print('Platform Hata Detayları: ${error.details}');
      }
    }
    
    return null;
  }
}

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      if (kDebugMode) {
        print('Sign Out Error: $error');
      }
    }
  }
    Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}