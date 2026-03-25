import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_model.dart';

class AppService {
  // Firebase collection reference
  final CollectionReference _appCollection =
      FirebaseFirestore.instance.collection('apps');

  /// Fetch all apps (main method)
  Future<List<AppModel>> fetchApps() async {
    try {
      final snapshot = await _appCollection.get();

      return snapshot.docs
          .map((doc) => AppModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error fetching apps: $e');
      return [];
    }
  }

  /// Same as fetchApps (kept for flexibility)
  Future<List<AppModel>> getAllApps() async {
    return fetchApps();
  }

  /// Fetch recommended apps (random for now)
  Future<List<AppModel>> getRecommendedApps() async {
    try {
      final appsList = await fetchApps();
      appsList.shuffle();
      return appsList;
    } catch (e) {
      print('Error fetching recommended apps: $e');
      return [];
    }
  }

  /// Add new app
  Future<void> addApp(AppModel app) async {
    try {
      await _appCollection.add(app.toMap());
    } catch (e) {
      print('Error adding app: $e');
    }
  }

  /// Get apps by category
  Future<List<AppModel>> getAppsByCategory(String category) async {
    try {
      final snapshot =
          await _appCollection.where('category', isEqualTo: category).get();

      return snapshot.docs
          .map((doc) => AppModel.fromMap(
                doc.data() as Map<String, dynamic>,
                id: doc.id,
              ))
          .toList();
    } catch (e) {
      print('Error fetching apps by category: $e');
      return [];
    }
  }

  /// Fetch single app by ID
  Future<AppModel?> getAppById(String id) async {
    try {
      final doc = await _appCollection.doc(id).get();

      if (doc.exists) {
        return AppModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching app by ID: $e');
      return null;
    }
  }
}
