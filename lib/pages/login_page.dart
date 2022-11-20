import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_user_08/pages/launcher_page.dart';
import 'package:ecom_user_08/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../auth/authservice.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../providers/notification_provider.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errMsg = '';
  late UserProvider userProvider;

  @override
  void didChangeDependencies() {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Provide a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  controller: _passwordController,
                  //obscureText: true,
                  decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password(at least 6 characters)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Provide a valid password';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _authenticate(true);
                },
                child: const Text('Login'),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                ),
                onPressed: _signInWithGoogle,
                label: const Text('Sign In with Google'),
              ),
              Row(
                children: [
                  const Text('New User?'),
                  TextButton(
                    onPressed: () {
                      _authenticate(false);
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Forgot password',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () {
                      AuthService.forgotPassword();
                    },
                    child: const Text('Click Here'),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  _loginAsGuest();
                },
                child: const Text('Login as Guest'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errMsg,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticate(bool tag) async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait', dismissOnTap: false);
      final email = _emailController.text;
      final password = _passwordController.text;
      try {
        UserCredential credential;
        if (tag) {
          credential = await AuthService.login(email, password);
        } else {
          if (AuthService.currentUser != null) {
            //turn anonymous account into a real account
            final credential =
                EmailAuthProvider.credential(email: email, password: password);
            await _registerAnonymousUser(credential);
          } else {
            //normal registration
            credential = await AuthService.register(email, password);
            final userModel = UserModel(
              userId: credential.user!.uid,
              email: credential.user!.email!,
              userCreationTime:
                  Timestamp.fromDate(credential.user!.metadata.creationTime!),
            );
            await userProvider.addUser(userModel);
            final notificationModel = NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: NotificationType.user,
              message: 'A new user ${userModel.email} has joined!',
              userModel: userModel,
            );
            await Provider.of<NotificationProvider>(context, listen: false)
                .addNotification(notificationModel);
          }
        }
        EasyLoading.dismiss();
        if (mounted) {
          Navigator.pushReplacementNamed(context, LauncherPage.routeName);
        }
      } on FirebaseAuthException catch (error) {
        EasyLoading.dismiss();
        setState(() {
          _errMsg = error.message!;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    if (AuthService.currentUser != null) {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential =
          GoogleAuthProvider.credential(idToken: googleAuth?.idToken);
      await _registerAnonymousUser(credential);
    } else {
      try {
        final credential = await AuthService.signInWithGoogle();
        final userExists =
            await userProvider.doesUserExist(credential.user!.uid);
        if (!userExists) {
          EasyLoading.show(status: 'Redirecting...');
          final userModel = UserModel(
            userId: credential.user!.uid,
            email: credential.user!.email!,
            displayName: credential.user!.displayName,
            imageUrl: credential.user!.photoURL,
            phone: credential.user!.phoneNumber,
            userCreationTime: Timestamp.fromDate(DateTime.now()),
          );
          await userProvider.addUser(userModel);
        }
      } catch (error) {
        EasyLoading.dismiss();
        rethrow;
      }
    }
    EasyLoading.dismiss();
    if (mounted) {
      Navigator.pushReplacementNamed(context, LauncherPage.routeName);
    }
  }

  void _loginAsGuest() {
    EasyLoading.show(status: 'Please Wait');
    AuthService.loginAsGuest().then((value) {
      EasyLoading.dismiss();
      Navigator.pushReplacementNamed(context, LauncherPage.routeName);
    }).catchError((error) {
      EasyLoading.dismiss();
    });
  }

  Future<void> _registerAnonymousUser(AuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
      print('IS CREDENTIAL NULL : ${userCredential == null}');
      if (userCredential!.user != null) {
        final userModel = UserModel(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          imageUrl: userCredential.user!.photoURL,
          phone: userCredential.user!.phoneNumber,
          userCreationTime:
              Timestamp.fromDate(userCredential.user!.metadata.creationTime!),
        );
        await userProvider.addUser(userModel);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          print("Unknown error.");
      }
    }
  }
}
