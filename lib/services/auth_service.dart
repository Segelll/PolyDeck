import 'package:firebase_auth/firebase_auth.dart';
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
      print("Google Sign-In iptal edildi");
      return null;
    }

    print('Google Kullanıcısı Bulundu: ${googleUser.email}');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    print('Google Kimlik Bilgileri Alındı');
    print('Access Token: ${googleAuth.accessToken}');
    print('ID Token: ${googleAuth.idToken}');

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print('Firebase Kimlik Bilgileri Oluşturuldu');

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    
    print('Firebase Girişi Başarılı: ${authResult.user?.email}');

    return authResult.user;
  } catch (error) {
    print('Google Sign-In Hatası: $error');
    
    if (error is FirebaseAuthException) {
      print('Firebase Auth Hatası Kodu: ${error.code}');
      print('Hata Mesajı: ${error.message}');
    } else if (error is PlatformException) {
      print('Platform Hatası Kodu: ${error.code}');
      print('Platform Hata Mesajı: ${error.message}');
      print('Platform Hata Detayları: ${error.details}');
    }
    
    return null;
  }
}

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      print('Sign Out Error: $error');
    }
  }
    Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}