import 'package:postgrest/postgrest.dart';

/// Classe utilitaire pour gérer les réponses de Supabase
class SupabaseHelper {
  /// Vérifie si une réponse Supabase contient une erreur
  static bool hasError(PostgrestResponse response) {
    return response.status < 200 || response.status >= 300;
  }

  /// Obtient le message d'erreur d'une réponse Supabase
  static String getErrorMessage(PostgrestResponse response) {
    if (!hasError(response)) {
      return '';
    }
    
    // Essayer d'extraire un message d'erreur structuré si disponible
    try {
      final Map<String, dynamic> errorData = response.data as Map<String, dynamic>;
      if (errorData.containsKey('message')) {
        return errorData['message'] as String;
      } else if (errorData.containsKey('error')) {
        return errorData['error'] as String;
      }
    } catch (e) {
      // Ignorer les erreurs lors de l'extraction du message
    }
    
    // Retourner un message basé sur le code de statut
    return 'Erreur ${response.status}';
  }
}
