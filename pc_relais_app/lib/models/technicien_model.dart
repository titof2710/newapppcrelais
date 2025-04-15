import 'user_model.dart';

class TechnicienModel extends UserModel {
  final List<String> speciality;
  final int experienceYears;
  final List<String> certifications;
  final List<String> assignedRepairs;

  TechnicienModel({
    required super.id,
    required super.email,
    required super.name,
    required super.phoneNumber,
    super.profileImageUrl,
    super.address,
    required super.createdAt,
    this.speciality = const [],
    this.experienceYears = 0,
    this.certifications = const [],
    this.assignedRepairs = const [],
  }) : super(userType: 'technicien');

  factory TechnicienModel.fromJson(Map<String, dynamic> json) {
    return TechnicienModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      speciality: json['speciality'] != null 
          ? List<String>.from(json['speciality']) 
          : [],
      experienceYears: json['experience_years'] as int? ?? 0,
      certifications: json['certifications'] != null 
          ? List<String>.from(json['certifications']) 
          : [],
      assignedRepairs: json['assigned_repairs'] != null 
          ? List<String>.from(json['assigned_repairs']) 
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['speciality'] = speciality;
    data['experience_years'] = experienceYears;
    data['certifications'] = certifications;
    data['assigned_repairs'] = assignedRepairs;
    return data;
  }

  @override
  TechnicienModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? userType, // Ignoré car toujours 'technicien'
    String? profileImageUrl,
    String? address,
    DateTime? createdAt,
    List<String>? speciality,
    int? experienceYears,
    List<String>? certifications,
    List<String>? assignedRepairs,
  }) {
    return TechnicienModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      speciality: speciality ?? this.speciality,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      assignedRepairs: assignedRepairs ?? this.assignedRepairs,
    );
  }
}
