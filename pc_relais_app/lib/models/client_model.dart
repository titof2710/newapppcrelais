import 'user_model.dart';
import 'safe_list_from_json.dart';

/// Modèle représentant un client dans l'application
class ClientModel extends UserModel {
  final List<String> repairIds;

  ClientModel({
    required super.uuid, // Ajout uuid
    required super.email,
    required super.name,
    required super.phoneNumber,
    super.profileImageUrl,
    super.address,
    required super.createdAt,
    this.repairIds = const [],
  }) : super(userType: 'client');

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      uuid: json['uuid'] as String,
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      profileImageUrl: json['profile_image'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      repairIds: safeListFromJson(json['repair_ids']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Séparer le nom complet en prénom et nom
    List<String> nameParts = name.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    return {
      'uuid': uuid,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'user_type': userType,
      'profile_image': profileImageUrl,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'repair_ids': repairIds,
    };
  }

  @override
  ClientModel copyWith({

    String? email,
    String? name,
    String? phoneNumber,
    String? userType, // Ignoré car toujours 'client'
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
    List<String>? repairIds,
  }) {
    return ClientModel(

      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      repairIds: repairIds ?? this.repairIds,
    );
  }
}
