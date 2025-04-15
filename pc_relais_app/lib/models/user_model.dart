class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String userType; // 'client', 'point_relais', 'technicien' ou 'admin'
  final String? profileImageUrl;
  final String? address;
  final DateTime createdAt;

  UserModel({
    required this.id,
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
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      userType: json['user_type'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
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
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'user_type': userType,
      'profile_image_url': profileImageUrl,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
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
