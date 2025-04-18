// Fonction utilitaire globale pour parser en toute sécurité un champ en List<String>
import 'dart:convert';

List<String> safeListFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) return List<String>.from(value);
  if (value is String) {
    if (value.trim() == "[]") return [];
    // Si c'est une chaîne qui ressemble à une liste JSON
    if (value.startsWith('[') && value.endsWith(']')) {
      try {
        final List<dynamic> parsed = jsonDecode(value);
        return List<String>.from(parsed);
      } catch (e) {
        print('Erreur lors du parsing de la liste: $e');
        return [];
      }
    }
    // Si c'est juste une chaîne, la retourner comme élément unique
    return [value];
  }
  return [];
}
