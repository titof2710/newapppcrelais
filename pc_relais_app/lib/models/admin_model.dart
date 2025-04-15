import 'user_model.dart';

/// Modèle pour les administrateurs du système
class AdminModel extends UserModel {
  final List<String> permissions;
  final String role;

  AdminModel({
    required String id,
    required String email,
    required String name,
    required String phoneNumber,
    String? profileImageUrl,
    String? address,
    required DateTime createdAt,
    this.permissions = const [],
    this.role = 'admin',
  }) : super(
          id: id,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl,
          address: address,
          createdAt: createdAt,
          userType: 'admin',
        );

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    // Afficher les clés disponibles pour le débogage
    print('Clés disponibles dans json: ${json.keys.join(', ')}');
    
    // Gérer différentes structures possibles pour le nom
    String name = '';
    if (json['name'] != null) {
      name = json['name'] as String;
    } else if (json['first_name'] != null || json['last_name'] != null) {
      name = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }
    
    // Gérer différentes structures possibles pour le téléphone
    String phoneNumber = '';
    if (json['phone_number'] != null) {
      phoneNumber = json['phone_number'] as String;
    } else if (json['phone'] != null) {
      phoneNumber = json['phone'] as String;
    }
    
    // Gérer la date de création
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'] as String);
    } catch (e) {
      print('Erreur lors du parsing de la date: $e');
      createdAt = DateTime.now();
    }
    
    return AdminModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: name,
      phoneNumber: phoneNumber,
      profileImageUrl: json['profile_image_url'] as String?,
      address: json['address'] as String?,
      createdAt: createdAt,
      permissions: json['permissions'] != null ? List<String>.from(json['permissions']) : [],
      role: json['role'] as String? ?? 'admin',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['permissions'] = permissions;
    data['role'] = role;
    return data;
  }

  @override
  AdminModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
    List<String>? permissions,
    String? role,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      permissions: permissions ?? this.permissions,
      role: role ?? this.role,
    );
    // userType est ignoré car il est toujours 'admin' dans AdminModel
    // profileImageUrl et address sont gérés par la classe parente
  }
}
