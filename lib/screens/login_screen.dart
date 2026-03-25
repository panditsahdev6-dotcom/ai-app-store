import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // 🔥 GOOGLE SIGN IN
  Future<void> signInWithGoogle() async {
    try {
      setState(() => isLoading = true);

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.saveUserToFirestore(user);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // 🔥 EMAIL LOGIN
  Future<void> loginWithEmail() async {
    try {
      setState(() => isLoading = true);

      User? user =
          await _auth.login(emailCtrl.text.trim(), passCtrl.text.trim());

      if (user != null) {
        await _firestore.saveUserToFirestore(user);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI App Store Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),

                    // EMAIL
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),

                    // PASSWORD
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    // LOGIN BUTTON
                    ElevatedButton(
                      onPressed: loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Login"),
                    ),

                    SizedBox(height: 10),

                    // GOOGLE BUTTON
                    ElevatedButton.icon(
                      onPressed: signInWithGoogle,
                      icon: Icon(Icons.login),
                      label: Text("Sign in with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 10),

                    // SIGNUP
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SignupScreen()),
                        );
                      },
                      child: Text("Signup Here"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}