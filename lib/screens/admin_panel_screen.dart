import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // 🔹 Controllers (Upload Form)
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final iconController = TextEditingController();
  final apkController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // 🚀 ADMIN DIRECT UPLOAD
  Future<void> uploadApp() async {
    if (nameController.text.isEmpty ||
        descController.text.isEmpty ||
        apkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('apps').add({
      "name": nameController.text,
      "description": descController.text,
      "category": categoryController.text,
      "iconUrl": iconController.text,
      "downloadUrl": apkController.text,
      "version": "1.0.0",
      "forceUpdate": false,
      "rating": 0,
      "downloads": 0,
      "status": "approved",
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    nameController.clear();
    descController.clear();
    categoryController.clear();
    iconController.clear();
    apkController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🚀 App Uploaded Successfully")),
    );
  }

  // ✅ APPROVE APP
  Future<void> approveApp(DocumentSnapshot doc) async {
    var data = doc.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('apps').add({
      ...data,
      "status": "approved",
      "downloads": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('uploads')
        .doc(doc.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ App Approved")),
    );
  }

  // ❌ REJECT APP
  Future<void> rejectApp(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance
        .collection('uploads')
        .doc(doc.id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ App Rejected")),
    );
  }

  // 🗑 DELETE LIVE APP
  Future<void> deleteApp(String id) async {
    await FirebaseFirestore.instance.collection('apps').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🗑 App Deleted")),
    );
  }

  // 🔥 UI START
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("😈 Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Upload"),
            Tab(text: "Pending"),
            Tab(text: "Live Apps"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // 🚀 TAB 1: ADMIN UPLOAD
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: "App Name")),
                TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
                TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category")),
                TextField(controller: iconController, decoration: InputDecoration(labelText: "Icon URL")),
                TextField(controller: apkController, decoration: InputDecoration(labelText: "APK URL")),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : uploadApp,
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Upload App 🚀"),
                )
              ],
            ),
          ),

          // 🔥 TAB 2: PENDING APPS
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('uploads')
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(child: Text("No Pending Apps"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => approveApp(doc),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => rejectApp(doc),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // 🔥 TAB 3: LIVE APPS
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('apps')
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(child: Text("No Live Apps"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(data['name'] ?? ''),
                      subtitle: Text(
                        "Downloads: ${data['downloads'] ?? 0}",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteApp(doc.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}