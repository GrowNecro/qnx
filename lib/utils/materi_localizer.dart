import '../main.dart' show languageManager;

/// Helper to get localized text from materi.json
/// Supports both old format (String) and new format (Map with en/id keys)
class MateriLocalizer {
  /// Get localized string from a field that could be String or Map
  static String getText(dynamic field, {String fallback = ''}) {
    if (field == null) return fallback;
    
    // Old format: direct string
    if (field is String) return field;
    
    // New format: {en: "...", id: "..."}
    if (field is Map) {
      final lang = languageManager.languageCode;
      // Try current language first
      if (field.containsKey(lang)) {
        return field[lang]?.toString() ?? fallback;
      }
      // Fallback to English
      if (field.containsKey('en')) {
        return field['en']?.toString() ?? fallback;
      }
      // Fallback to Indonesian
      if (field.containsKey('id')) {
        return field['id']?.toString() ?? fallback;
      }
      // Return first available value
      if (field.isNotEmpty) {
        return field.values.first?.toString() ?? fallback;
      }
    }
    
    return fallback;
  }
  
  /// Get judul (title) from materi item
  static String getJudul(Map<String, dynamic> materi) {
    return getText(materi['judul'], fallback: 'Untitled');
  }
  
  /// Get judullatihan (exercise title) from materi item
  static String getJudulLatihan(Map<String, dynamic> materi) {
    return getText(materi['judullatihan'], fallback: 'Exercise');
  }
  
  /// Get latihan (exercise content) from materi item
  static String getLatihan(Map<String, dynamic> materi) {
    return getText(materi['latihan'], fallback: '');
  }
  
  /// Get jawabansistemteks (system answer text) from materi item
  static String getJawabanSistem(Map<String, dynamic> materi) {
    return getText(materi['jawabansistemteks'], fallback: '');
  }
  
  /// Check if a materi's judullatihan matches a given string
  /// Works with both old (String) and new (Map) formats
  static bool matchesJudulLatihan(Map<String, dynamic> materi, String target) {
    final field = materi['judullatihan'];
    if (field == null) return false;
    
    // Old format: direct string comparison
    if (field is String) {
      return field == target;
    }
    
    // New format: check if any language matches
    if (field is Map) {
      return field.values.any((v) => v?.toString() == target);
    }
    
    return false;
  }
  
  /// Find materi by judullatihan from a list
  static Map<String, dynamic>? findByJudulLatihan(
    List<Map<String, dynamic>> materiList, 
    String judullatihan,
  ) {
    try {
      return materiList.firstWhere(
        (m) => matchesJudulLatihan(m, judullatihan),
      );
    } catch (_) {
      return null;
    }
  }
}
