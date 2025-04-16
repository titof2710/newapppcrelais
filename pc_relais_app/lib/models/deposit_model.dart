import 'package:uuid/uuid.dart';

class DepositModel {
  final String id;
  final String clientId;
  final String firstName;
  final String lastName;
  final String email;
  final String deviceType;
  final String brand;
  final String model;
  final String? serialNumber;
  final String? devicePassword;
  final String pointRelaisId;
  final String? issue;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final String status; // 'pending', 'received', 'cancelled'

  DepositModel({
    String? id,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.deviceType,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.devicePassword,
    required this.pointRelaisId,
    this.issue,
    this.photoUrls,
    DateTime? createdAt,
    this.status = 'pending',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'device_type': deviceType,
        'brand': brand,
        'model': model,
        'serial_number': serialNumber,
        'device_password': devicePassword,
        'point_relais_id': pointRelaisId,
        'issue': issue,
        'photo_urls': photoUrls,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };

  factory DepositModel.fromJson(Map<String, dynamic> json) => DepositModel(
        id: json['id'] as String?,
        clientId: json['client_id'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        deviceType: json['device_type'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        serialNumber: json['serial_number'] as String?,
        devicePassword: json['device_password'] as String?,
        pointRelaisId: json['point_relais_id'] as String,
        issue: json['issue'] as String?,
        photoUrls: (json['photo_urls'] as List?)?.map((e) => e.toString()).toList(),
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        status: json['status'] as String? ?? 'pending',
      );
}
