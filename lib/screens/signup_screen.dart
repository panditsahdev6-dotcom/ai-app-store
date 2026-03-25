import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI App Store Signup")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var user = await _auth.signup(emailCtrl.text, passCtrl.text);
                if (user != null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed")));
                }
              },
              child: Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
