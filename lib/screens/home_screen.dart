import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_card.dart';
import '../models/app_model.dart';
import 'profile_screen.dart';
import 'developer_upload_screen.dart';
import 'admin_panel_screen.dart'; // ✅ NEW ADMIN PANEL

// 🔥 Download function
Future<void> openDownload(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    debugPrint("Download failed");
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate();
    });
  }

  // 🔥 Version Compare
  bool isUpdateAvailable(String current, String latest) {
    List<int> c = current.split('.').map(int.parse).toList();
    List<int> l = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < l.length; i++) {
      if (i >= c.length) return true;
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }

  // 🔥 Update Check
  Future<void> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      String currentVersion = info.version;

      final doc = await FirebaseFirestore.instance
          .collection('apps')
          .doc('zvetxDkFAHCbgq92vgud')
          .get();

      if (!doc.exists) return;

      String latestVersion = doc['version'] ?? "1.0.0";
      String downloadUrl = doc['downloadUrl'] ?? "";
      bool forceUpdate = doc['forceUpdate'] ?? false;

      if (isUpdateAvailable(currentVersion, latestVersion)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("New Update Available 🚀"),
            action: SnackBarAction(
              label: "UPDATE",
              onPressed: () {
                openDownload(downloadUrl);
              },
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          showDialog(
            context: context,
            barrierDismissible: !forceUpdate,
            builder: (_) => AlertDialog(
              title: const Text("Update Available 🚀"),
              content: const Text("New version available"),
              actions: [
                if (!forceUpdate)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Later"),
                  ),
                TextButton(
                  onPressed: () async {
                    await openDownload(downloadUrl);
                  },
                  child: const Text("Update Now"),
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  // 🔥 Category Button
  Widget categoryButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedCategory == category ? Colors.blue : Colors.grey,
        ),
        child: Text(category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("AI App Store"),
        centerTitle: true,
        actions: [

          // 👤 PROFILE
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(),
                ),
              );
            },
          ),

          // 🔥 MENU
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "upload") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DeveloperUploadScreen(),
                  ),
                );
              } else if (value == "admin") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPanelScreen(), // ✅ UPDATED
                  ),
                );
              }
            },
            itemBuilder: (context) => [

              const PopupMenuItem(
                value: "upload",
                child: Text("📤 Upload App"),
              ),

              // 🔐 ADMIN ONLY
              if (user?.email == "kumartinku24473@gmail.com")
                const PopupMenuItem(
                  value: "admin",
                  child: Text("🔐 Admin Panel"),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔥 CATEGORY FILTER
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 10),
                categoryButton("All"),
                categoryButton("AI"),
                categoryButton("Games"),
                categoryButton("Tools"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 APP LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedCategory == "All"
                    ? FirebaseFirestore.instance
                        .collection('apps')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('apps')
                        .where("category", isEqualTo: selectedCategory)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text("No Apps Available 😔"));
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final app = AppModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        id: doc.id,
                      );

                      return AppCard(app: app);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}