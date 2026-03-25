class AppModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String downloadUrl;
  final String category;

  // 🔥 Advanced fields
  final int downloads;
  final String version;
  final bool forceUpdate;

  AppModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.downloadUrl,
    required this.category,
    required this.downloads,
    required this.version,
    required this.forceUpdate,
  });

  // 🔥 Firestore → AppModel (SAFE + PRO)
  factory AppModel.fromMap(Map<String, dynamic> data, {required String id}) {
    return AppModel(
      id: id,

      name: (data['name'] ?? '').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      iconUrl: (data['iconUrl'] ?? '').toString().trim(),
      downloadUrl: (data['downloadUrl'] ?? '').toString().trim(),
      category: (data['category'] ?? 'General').toString().trim(),

      downloads: _parseInt(data['downloads']),
      version: (data['version'] ?? '1.0.0').toString(),
      forceUpdate: _parseBool(data['forceUpdate']),
    );
  }

  // 🔥 AppModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'downloadUrl': downloadUrl,
      'category': category,
      'downloads': downloads,
      'version': version,
      'forceUpdate': forceUpdate,
    };
  }

  // 🔥 Helper: Safe int parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  // 🔥 Helper: Safe bool parsing
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  // 🔥 Copy with (future updates ke liye)
  AppModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? downloadUrl,
    String? category,
    int? downloads,
    String? version,
    bool? forceUpdate,
  }) {
    return AppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      category: category ?? this.category,
      downloads: downloads ?? this.downloads,
      version: version ?? this.version,
      forceUpdate: forceUpdate ?? this.forceUpdate,
    );
  }
}