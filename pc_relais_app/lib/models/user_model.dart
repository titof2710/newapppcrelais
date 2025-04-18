class UserModel {
  final String uuid; // <-- Identifiant unique utilisateur
  final String email;
  final String name;
  final String phoneNumber;
  final String userType; // 'client', 'point_relais', 'technicien' ou 'admin'
  final String? profileImageUrl; // Correspond à la colonne 'profile_image' dans la table users
  final String? address;
  final DateTime createdAt;

  UserModel({
    required this.uuid, // <-- Ajout dans le constructeur
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.address,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'] as String, // <-- Ajout ici
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      userType: json['user_type'] as String,
      profileImageUrl: json['profile_image'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    // Séparer le nom complet en prénom et nom
    List<String> nameParts = name.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    return {
      'uuid': uuid, // <-- Ajout dans toJson
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'user_type': userType,
      'profile_image': profileImageUrl,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uuid,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
