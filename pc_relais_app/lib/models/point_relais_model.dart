import 'dart:convert';
import 'user_model.dart';

/// Modèle représentant un point relais dans l'application
class PointRelaisModel extends UserModel {
  final String shopName;
  final String shopAddress;
  final List<String> openingHours;
  final int storageCapacity;
  final int currentStorageUsed; // Nombre d'appareils actuellement stockés
  final List<String> pendingRepairIds;
  final List<String> currentRepairIds;

  PointRelaisModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phoneNumber,
    super.profileImageUrl,
    super.address,
    required super.createdAt,
    required this.shopName,
    required this.shopAddress,
    this.openingHours = const [],
    this.storageCapacity = 10,
    this.currentStorageUsed = 0,
    this.pendingRepairIds = const [],
    this.currentRepairIds = const [],
  }) : super(userType: 'point_relais');

  factory PointRelaisModel.fromJson(Map<String, dynamic> json) {
    return PointRelaisModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      shopName: json['shop_name'] as String,
      shopAddress: json['shop_address'] as String,
      openingHours: (() {
        final raw = json['opening_hours'];
        if (raw == null) {
          return <String>[];
        } else if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        } else if (raw is String) {
          try {
            // Peut-être une chaîne JSON
            final decoded = jsonDecode(raw);
            if (decoded is List) {
              return decoded.map((e) => e.toString()).toList();
            }
          } catch (_) {}
          // Sinon, on retourne la chaîne dans une liste
          return [raw];
        } else {
          return <String>[];
        }
      })(),
      storageCapacity: json['storage_capacity'] as int? ?? 10,
      currentStorageUsed: json['current_storage_used'] as int? ?? 0,
      pendingRepairIds: json['pending_repair_ids'] != null 
          ? List<String>.from(json['pending_repair_ids']) 
          : [],
      currentRepairIds: json['current_repair_ids'] != null 
          ? List<String>.from(json['current_repair_ids']) 
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['shop_name'] = shopName;
    data['shop_address'] = shopAddress;
    data['opening_hours'] = openingHours;
    data['storage_capacity'] = storageCapacity;
    data['current_storage_used'] = currentStorageUsed;
    data['pending_repair_ids'] = pendingRepairIds;
    data['current_repair_ids'] = currentRepairIds;
    return data;
  }

  @override
  PointRelaisModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType, // Ignoré car toujours 'point_relais'
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
    String? shopName,
    String? shopAddress,
    List<String>? openingHours,
    int? storageCapacity,
    int? currentStorageUsed,
    List<String>? pendingRepairIds,
    List<String>? currentRepairIds,
  }) {
    return PointRelaisModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      openingHours: openingHours ?? this.openingHours,
      storageCapacity: storageCapacity ?? this.storageCapacity,
      currentStorageUsed: currentStorageUsed ?? this.currentStorageUsed,
      pendingRepairIds: pendingRepairIds ?? this.pendingRepairIds,
      currentRepairIds: currentRepairIds ?? this.currentRepairIds,
    );
  }
}
