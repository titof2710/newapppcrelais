import 'user_model.dart';
import 'safe_list_from_json.dart';

class TechnicienModel extends UserModel {
  final List<String> speciality;
  final int experienceYears;
  final List<String> certifications;
  final List<String> assignedRepairs;

  TechnicienModel({
    required super.uuid, // Ajout uuid
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
      uuid: json['uuid'] as String,
      email: json['email'] as String,
      name: json['first_name'] != null && json['last_name'] != null
          ? '${json['first_name']} ${json['last_name']}'
          : (json['first_name'] ?? json['last_name'] ?? ''),
      phoneNumber: json['phone'] as String,
      profileImageUrl: json['profile_image'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      speciality: safeListFromJson(json['speciality']),
      experienceYears: json['experience_years'] as int? ?? 0,
      certifications: safeListFromJson(json['certifications']),
      assignedRepairs: safeListFromJson(json['assigned_repairs']),
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

      uuid: uuid ?? this.uuid,
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
