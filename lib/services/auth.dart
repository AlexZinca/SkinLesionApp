import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:my_camera/models/user.dart' as us;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user obj based on FirebaseUser
  us.User? _userFromFirebaseUser(User? user) {
    return user != null ? us.User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<us.User?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));

  }

  // sign in with Email & Password
  Future<dynamic> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user;
      if (result.user != null) {
        if (result.user!.emailVerified == false) {
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Email is not verified',
          );
        }
        user = result.user;
        return user;//_userFromFirebaseUser(user);;
      } else
        return null;
    } catch (e) {
      ////print(e.toString());
      return null;
    }
  }

  // register with Email & Password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      result.user!.sendEmailVerification();

      if (!result.user!.emailVerified) {
        await signOut();
        return false;
      } else {
        await signOut();
        return null;
      }
    } catch (e) {
      ////print(e.toString());
      return null;
    }
  }

  Future<void> sendEmailVerification(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user!.sendEmailVerification();
    } catch (e) {
      print(e.toString());
      //return null;
    }
  }
/*
  Future<dynamic> signInWithGoogle() async{

    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken
      );

      UserCredential x = await FirebaseAuth.instance.signInWithCredential(
          credential);

      User? user = x.user;
      return user;

      /*if(kDebugMode){
        print(user.user?.displayName);
      }*/
    }catch(e, str){
      print('$e: $str');
    }
  }
 */
  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      ////print(e.toString());
      return null;
    }
  }

  Future deleteUser(String email, String password) async {
    try {
      User user = await _auth.currentUser!;
      AuthCredential credentials =
      EmailAuthProvider.credential(email: email, password: password);
      UserCredential result = await user.reauthenticateWithCredential(credentials);

      await result.user!.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
