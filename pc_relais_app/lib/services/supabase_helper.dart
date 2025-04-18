import 'package:postgrest/postgrest.dart';

/// Classe utilitaire pour gérer les réponses de Supabase
class SupabaseHelper {
  /// Vérifie si une réponse Supabase contient une erreur
  static bool hasError(dynamic response) {
    // Si la réponse est une Map avec 'code' ou 'error', c'est une erreur
    if (response is Map && (response.containsKey('code') || response.containsKey('error'))) {
      return true;
    }
    // Une liste (même vide) N'EST PAS une erreur
    if (response is List) {
      return false;
    }
    // null est une erreur
    if (response == null) {
      return true;
    }
    // Tout le reste n'est pas une erreur
    return false;
  }

  /// Obtient le message d'erreur d'une réponse Supabase
  static String getErrorMessage(dynamic response) {
    if (!hasError(response)) {
      return '';
    }
    
    // Essayer d'extraire un message d'erreur structuré si disponible
    // For the new API, try to extract error message from response.
    if (response is Map && response.containsKey('message')) {
      return 'Erreur : ${response['message']}';
    } else if (response is Map && response.containsKey('error')) {
      return 'Erreur : ${response['error']}';
    } else if (response is Map && response.containsKey('code')) {
      return 'Erreur : ${response['code']}';
    }
    return 'Erreur inconnue';
  }
}
