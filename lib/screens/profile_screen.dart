import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text(
                "No user logged in",
                style: TextStyle(fontSize: 18),
              ),
            )
          : FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: getUserData(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      /// Profile Image
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: user!.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user!.photoURL == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),

                      const SizedBox(height: 20),

                      /// Name
                      Text(
                        user!.displayName ?? "No Name",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Email
                      Text(
                        user!.email ?? "No Email",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Extra Firestore Info (Optional)
                      if (snapshot.hasData && snapshot.data!.data() != null)
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Account Info",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "User ID: ${user!.uid}",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      /// Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              "Logout",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }
}