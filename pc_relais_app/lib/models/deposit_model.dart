import 'package:uuid/uuid.dart';

class DepositModel {
  final String id;
  final String code; // Ajouté pour identifiant texte
  final String? clientId;
  final String? firebaseClientId; // Ajout pour gérer les Firebase ID
  final String firstName;
  final String lastName;
  final String email;
  final String deviceType;
  final String brand;
  final String model;
  final String? serialNumber;
  final String? devicePassword;
  final String? os;
  final String? accessories;
  final String? notes;
  final DateTime? depositDate;
  final String pointRelaisId;
  final String? issue;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final String status; // 'pending', 'received', 'cancelled'

  DepositModel({
    String? id,
    String? code,
    required this.clientId,
    this.firebaseClientId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.deviceType,
    required this.brand,
    required this.model,
    this.serialNumber,
    this.devicePassword,
    this.os,
    this.accessories,
    this.notes,
    this.depositDate,
    required this.pointRelaisId,
    this.issue,
    this.photoUrls,
    DateTime? createdAt,
    this.status = 'pending',
  })  : id = id != null && isValidUuid(id) ? id : const Uuid().v4(),
        code = code ?? _generateCode(),
        createdAt = createdAt ?? DateTime.now();

  static bool isValidUuid(String? value) {
    if (value == null) return false;
    final uuidRegExp = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegExp.hasMatch(value);
  }

  static String _generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return 'REP${random.toString().padLeft(6, '0')}';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'code': code,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'device_type': deviceType,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'device_password': devicePassword,
      'os': os,
      'accessories': accessories,
      'notes': notes,
      'deposit_date': depositDate?.toIso8601String(),
      'point_relais_id': pointRelaisId,
      'issue': issue,
      'photo_urls': photoUrls,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
    // Mapping strict :
    if (clientId != null && DepositModel.isValidUuid(clientId)) {
      map['client_id'] = clientId;
    }
    if (firebaseClientId != null && (clientId == null || !DepositModel.isValidUuid(clientId))) {
      map['firebase_client_id'] = firebaseClientId;
    }
    return map;
  }

  factory DepositModel.fromJson(Map<String, dynamic> json) => DepositModel(
        id: json['id'] as String?,
        code: json['code'] as String? ?? '',
        clientId: json['client_id'] as String?,
        firebaseClientId: json['firebase_client_id'] as String?,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        email: json['email'] as String,
        deviceType: json['device_type'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        serialNumber: json['serial_number'] as String?,
        devicePassword: json['device_password'] as String?,
        os: json['os'] as String?,
        accessories: json['accessories'] as String?,
        notes: json['notes'] as String?,
        depositDate: json['deposit_date'] != null ? DateTime.parse(json['deposit_date']) : null,
        pointRelaisId: json['point_relais_id'] as String,
        issue: json['issue'] as String?,
        photoUrls: (json['photo_urls'] as List<dynamic>?)?.cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
        status: json['status'] as String,
      );
}
