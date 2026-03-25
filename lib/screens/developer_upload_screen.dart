import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeveloperUploadScreen extends StatefulWidget {
  const DeveloperUploadScreen({super.key});

  @override
  State<DeveloperUploadScreen> createState() =>
      _DeveloperUploadScreenState();
}

class _DeveloperUploadScreenState
    extends State<DeveloperUploadScreen> {

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final apkController = TextEditingController();

  bool loading = false;

  // ✅ VALIDATION + UPLOAD
  Future<void> uploadApp() async {

    if (nameController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        apkController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('uploads').add({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
      "downloadUrl": apkController.text.trim(),
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Upload sent for approval")),
    );

    // clear fields
    nameController.clear();
    descController.clear();
    apkController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Your App 🚀"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Publish Your App 🚀",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Fill details below to submit your app",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // 🔹 App Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "App Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apps),
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 Description
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 APK URL
              TextField(
                controller: apkController,
                decoration: const InputDecoration(
                  labelText: "APK Download URL",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : uploadApp,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit App 🚀",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 💡 INFO BOX
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "ℹ️ Your app will be reviewed by admin before publishing.",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}