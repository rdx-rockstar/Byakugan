import 'package:firebase_auth/firebase_auth.dart';
import 'package:women_safety/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // cast Firebase User to custom user class
  User _userFromFirebaseUser(FirebaseUser user){
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // Authchange user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in anom
  Future signInAnom() async {
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // sign in with email and password
  Future signinWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // sign in with phone number
  Future signInWithPhoneNumber(String number) async {
    var status = '';
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
          print('code sent');
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('codeAutoRetrievalTimeout');
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      print('verificationFailed');
    };
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      print('verification complete');
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: '+91'+number,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
    );
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

}