import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static UserCredential? userCredential;
  static final _auth = FirebaseAuth.instance;
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    return credential;
  }

  static Future<UserCredential> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return credential;
  }

  static Future<UserCredential> loginAsGuest() {
    return _auth.signInAnonymously();
  }

  static Future<void> forgotPassword() {
    return _auth.sendPasswordResetEmail(email: 'tanvir.ahmad@gmail.com');
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // Once signed in, return the UserCredential
    userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential!;
  }

  static Future<void> logout() async {
    if (_auth.currentUser!.isAnonymous) {
      return _auth.currentUser!.delete();
    }
    return _auth.signOut();
  }
}
