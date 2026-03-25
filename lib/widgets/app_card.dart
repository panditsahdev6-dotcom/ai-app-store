import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_model.dart';

class AppCard extends StatelessWidget {
  final AppModel app;

  const AppCard({
    Key? key,
    required this.app,
  }) : super(key: key);

  Future<void> _handleDownload(BuildContext context) async {
    if (app.downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid download link")),
      );
      return;
    }

    try {
      Uri url = Uri.parse(app.downloadUrl);

      if (await canLaunchUrl(url)) {
        // 🔥 DOWNLOAD COUNT UPDATE
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(app.id) // 👈 जरूरी
            .update({
          "downloads": FieldValue.increment(1),
        });

        // 🚀 OPEN DOWNLOAD LINK
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open link")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error opening link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        // 📱 App Icon
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            app.iconUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
                child: const Icon(Icons.apps, size: 30),
              );
            },
          ),
        ),

        // 🏷 App Name
        title: Text(
          app.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // 📝 Description
        subtitle: Text(
          app.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // ⬇️ Download Button
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _handleDownload(context),
          child: const Text("Download"),
        ),
      ),
    );
  }
}