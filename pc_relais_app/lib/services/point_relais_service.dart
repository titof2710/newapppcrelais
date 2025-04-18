import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

/// Service pour gérer les fonctionnalités liées aux points relais
class PointRelaisService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();

  // Créer un nouveau point relais (réservé aux administrateurs)
  Future<UserModel> createPointRelais({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? address,
    required String shopName,
    required String shopAddress,
    required List<String> openingHours,
    required int storageCapacity,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebase_auth.User? user = userCredential.user;
      if (user == null) {
        throw Exception("L'inscription a échoué");
      }

      // Créer le profil point relais dans Supabase
      final Map<String, dynamic> pointRelaisData = {
        'id': user.uid,
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
        'address': address,
        'user_type': 'point_relais',
        'created_at': DateTime.now().toIso8601String(),
        'shop_name': shopName,
        'shop_address': shopAddress,
        'opening_hours': openingHours,
        'storage_capacity': storageCapacity,
      };

      await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .insert(pointRelaisData);

      // Créer un objet UserModel pour le retour
      final UserModel newPointRelais = UserModel(
        uuid: const Uuid().v4(),
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        userType: 'point_relais',
        createdAt: DateTime.now(),
      );

      return newPointRelais;
    } catch (e) {
      throw Exception('Erreur lors de la création du point relais: $e');
    }
  }

  // Obtenir tous les points relais
  Future<List<UserModel>> getAllPointRelais() async {
    try {
      final data = await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('user_type', 'point_relais');
      return (data as List).map((userData) => UserModel.fromJson(userData)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des points relais: $e');
    }
  }

  // Mettre à jour un point relais
  Future<void> updatePointRelais(UserModel pointRelais, {
    String? shopName,
    String? shopAddress,
    List<String>? openingHours,
    int? storageCapacity,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'uuid': pointRelais.uuid,
        'name': pointRelais.name,
        'email': pointRelais.email,
        'phone_number': pointRelais.phoneNumber,
        'address': pointRelais.address,
      };

      if (shopName != null) {
        updateData['shop_name'] = shopName;
      }

      if (shopAddress != null) {
        updateData['shop_address'] = shopAddress;
      }

      if (openingHours != null) {
        updateData['opening_hours'] = openingHours;
      }

      if (storageCapacity != null) {
        updateData['storage_capacity'] = storageCapacity;
      }

      await _supabaseService.client
          .from(SupabaseConfig.usersTable)
          .update(updateData)
          .eq('id', pointRelais.uuid);
      // La nouvelle API lève une exception en cas d'erreur
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du point relais: $e');
    }
  }
}
