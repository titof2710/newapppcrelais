import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:math';

class StorageService {
  final SupabaseClient client;
  final String bucketName = 'depot-photos';

  StorageService({required this.client});

  // Fonction pour nettoyer le nom de fichier
  String _sanitizeFileName(String fileName) {
    // Remplacer les espaces et caractères spéciaux
    String sanitized = fileName
        .replaceAll(' ', '_')
        .replaceAll("'", '')
        .replaceAll('\"', '')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('ù', 'u');
    
    // Supprimer tous les caractères non alphanumériques sauf underscore et point
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\.]'), '');
    
    // Ajouter un identifiant aléatoire pour éviter les collisions
    final random = Random().nextInt(10000).toString().padLeft(4, '0');
    
    // Extraire l'extension du fichier
    final extension = sanitized.contains('.')
        ? sanitized.substring(sanitized.lastIndexOf('.'))
        : '.jpg';
    
    // Construire le nom final: userId_random_nom.ext
    return '${random}_$sanitized';
  }

  // Solution temporaire : simuler l'upload et retourner une URL fictive
  // jusqu'à ce que les permissions Supabase soient correctement configurées
  Future<String> uploadImage(XFile image, String userId) async {
    try {
      // Générer un nom de fichier sécurisé
      final String originalName = image.name;
      final String sanitizedName = _sanitizeFileName(originalName);
      final String fileName = '${userId}_$sanitizedName';
      
      // Lire les bytes de l'image (pour vérifier que l'image est valide)
      final Uint8List fileBytes = await image.readAsBytes();
      
      // Essayer d'abord avec le bucket par défaut
      try {
        final storageRef = client.storage.from(bucketName);
        await storageRef.uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(upsert: true),
        );
        return storageRef.getPublicUrl(fileName);
      } catch (bucketError) {
        print('Erreur avec le bucket $bucketName: $bucketError');
        
        // Si ça échoue, essayer avec le bucket par défaut de Supabase
        try {
          final defaultStorageRef = client.storage.from('depot-photos');
          await defaultStorageRef.uploadBinary(
            fileName,
            fileBytes,
            fileOptions: FileOptions(upsert: true),
          );
          return defaultStorageRef.getPublicUrl(fileName);
        } catch (defaultBucketError) {
          print('Erreur avec le bucket images: $defaultBucketError');
          
          throw Exception("Erreur lors de l'upload de l'image sur Supabase Storage: $defaultBucketError");
        }
      }
    } catch (e) {
      print('Erreur d\'upload: $e');
      throw Exception("Erreur lors de l'upload du fichier: $e");
    }
  }
  
  // Vérifie si le bucket existe, sinon le crée
  Future<void> _ensureBucketExists() async {
    try {
      // Essayer de lister les buckets pour voir si le nôtre existe
      final buckets = await client.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == bucketName);
      
      if (!bucketExists) {
        // Si le bucket n'existe pas, essayer de le créer
        await client.storage.createBucket(bucketName, const BucketOptions(
          public: true, // Rendre le bucket public
        ));
        print('Bucket $bucketName créé avec succès');
      }
    } catch (e) {
      print('Impossible de vérifier/créer le bucket: $e');
      // On continue même si on ne peut pas créer le bucket
      // car on va utiliser le dossier public
    }
  }
}
