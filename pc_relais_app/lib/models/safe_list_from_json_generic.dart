import 'dart:convert';

/// Fonction utilitaire pour parser en toute sécurité une liste d'objets complexes depuis du JSON
List<T> safeListFromJsonGeneric<T>(dynamic value, T Function(dynamic) fromJson) {
  if (value == null) return [];
  if (value is List) return value.map(fromJson).toList();
  if (value is String) {
    if (value.trim() == "[]") return [];
    if (value.startsWith('[') && value.endsWith(']')) {
      try {
        final List<dynamic> parsed = jsonDecode(value);
        return parsed.map(fromJson).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
  return [];
}
