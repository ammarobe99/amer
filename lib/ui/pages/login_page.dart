import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:tamwelkom/ui/pages/add_user_detils.dart';
import '../../app/resources/constant/named_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, String> users = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

bool isLogin = false;
bool isSignUp = false;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      isLogin = true;
    } on FirebaseAuthException catch (e) {
      // WRONG EMAIL
      if (e.code == 'user-not-found') {
        // show error to user
        return 'User not found!';
      }

      // WRONG PASSWORD
      else if (e.code == 'wrong-password') {
        // show error to user
        return 'Wrong Password!';
      }
    }
    return null;
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      // Get current user
      User? user = userCredential.user;
      if (user == null) {
        return 'User creation failed';
      }

      // Add user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          "id": user.uid,
          "email": data.name!,
        },
      );
      isSignUp = true;
      debugPrint('Signup successful: ${data.name}');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Exception: ${e.toString()}');
      return 'An unexpected error occurred';
    }
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(
        cardTopPosition: 250,
        primaryColor: const Color.fromARGB(255, 111, 96, 246),
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 35,
        ),
      ),
      title: 'Finance company',
      logo: 'assets/images/business-and-finance.png',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (_) => AddUserInfo()));
        // return;

        if (isSignUp) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddUserInfo(),
            ),
          );
        } else {
          Navigator.of(context).pushNamed(NamedRoutes.navigationScreen);
        }
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
