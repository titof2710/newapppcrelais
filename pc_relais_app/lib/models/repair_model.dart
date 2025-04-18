import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'safe_list_from_json.dart';
import 'safe_list_from_json_generic.dart';

enum RepairStatus {
  pending,           // En attente
  waiting_drop,      // En attente de dépôt
  in_progress,       // Réparation en cours
  diagnosed,         // Diagnosticé
  waiting_for_parts, // Attente pièces
  completed,         // Terminée
  ready_for_pickup,  // Prêt pour retrait
  picked_up,         // Récupéré
  cancelled          // Annulé
}

class RepairModel {
  final String clientEmail;
  final String? devicePassword; // Mot de passe de la machine (optionnel)
  final List<String> accessories; // Accessoires fournis (ex: chargeur, câble, sacoche, etc.)
  final List<String> visualState; // État visuel à l'arrivée (ex: rayures, écran cassé, etc.)
  final String id;
  final String clientId;
  final String clientName; // Nom du client
  final String? pointRelaisId; // ID du point relais où l'appareil a été déposé
  final String? technicienId; // ID du technicien assigné à la réparation
  final String deviceType; // Type d'appareil (PC portable, PC fixe, etc.)
  final String brand;
  final String model;
  final String serialNumber;
  final String issue; // Description du problème
  final List<String> photos; // URLs des photos de l'appareil
  final RepairStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedCompletionDate;
  final double? estimatedPrice;
  final bool isPaid;
  final List<RepairNote> notes; // Notes et commentaires sur la réparation
  final List<RepairTask> tasks; // Tâches à effectuer pour la réparation

  RepairModel({
    String? id,
    required this.clientEmail,
    this.devicePassword,
    this.accessories = const [],
    this.visualState = const [],
    required this.clientId,
    required this.clientName,
    this.pointRelaisId,
    this.technicienId,
    required this.deviceType,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.issue,
    this.photos = const [],
    this.status = RepairStatus.waiting_drop,
    DateTime? createdAt,
    this.updatedAt,
    this.estimatedCompletionDate,
    this.estimatedPrice,
    this.isPaid = false,
    this.notes = const [],
    this.tasks = const [],
  }) : 
    this.id = id != null && RepairModel._isValidUuid(id) ? id : const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  static bool _isValidUuid(String? value) {
    if (value == null) return false;
    final uuidRegExp = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegExp.hasMatch(value);
  }

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    
    return RepairModel(
      clientEmail: json['client_email'] as String? ?? '',
      devicePassword: json['device_password'] as String?,

      accessories: safeListFromJson(json['accessories']),
      visualState: safeListFromJson(json['visual_state']),
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      pointRelaisId: json['point_relais_id'] as String?,
      technicienId: json['technicien_id'] as String?,
      deviceType: json['device_type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      serialNumber: json['serial_number'] as String,
      issue: json['issue'] as String,
      photos: safeListFromJson(json['photos']),
      status: RepairStatus.values.firstWhere(
        (e) => e.toString() == 'RepairStatus.${json['status']}',
        orElse: () => RepairStatus.waiting_drop,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'] as String) 
        : null,
      estimatedCompletionDate: json['estimated_completion_date'] != null 
        ? DateTime.parse(json['estimated_completion_date'] as String) 
        : null,
      estimatedPrice: json['estimated_price'] as double?,
      isPaid: json['is_paid'] as bool? ?? false,
      notes: safeListFromJsonGeneric(json['notes'], (x) => RepairNote.fromJson(x)),
      tasks: safeListFromJsonGeneric(json['tasks'], (x) => RepairTask.fromJson(x)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      
      'client_id': clientId,
      'client_name': clientName,
      'point_relais_id': pointRelaisId,
      'technicien_id': technicienId,
      'device_type': deviceType,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'issue': issue,
      'photos': photos,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'estimated_completion_date': estimatedCompletionDate?.toIso8601String(),
      'estimated_price': estimatedPrice,
      'is_paid': isPaid,
      'device_password': devicePassword,
      'accessories': accessories,
      'visual_state': visualState,
      // Pour les notes et tâches, nous pouvons les garder telles quelles car elles sont gérées séparément
      'notes': notes.map((note) => note.toJson()).toList(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  RepairModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? pointRelaisId,
    String? technicienId,
    String? deviceType,
    String? brand,
    String? model,
    String? serialNumber,
    String? issue,
    List<String>? photos,
    RepairStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? estimatedCompletionDate,
    double? estimatedPrice,
    bool? isPaid,
    List<RepairNote>? notes,
    List<RepairTask>? tasks,
    List<String>? accessories,
    List<String>? visualState,
    String? devicePassword,
  }) {
    return RepairModel(
      clientEmail: clientEmail ?? this.clientEmail ?? '',
      id: id ?? this.id ?? '',
      clientId: clientId ?? this.clientId ?? '',
      clientName: clientName ?? this.clientName ?? '',
      pointRelaisId: pointRelaisId ?? this.pointRelaisId ?? '',
      technicienId: technicienId ?? this.technicienId ?? '',
      deviceType: deviceType ?? this.deviceType ?? '',
      brand: brand ?? this.brand ?? '',
      model: model ?? this.model ?? '',
      serialNumber: serialNumber ?? this.serialNumber ?? '',
      issue: issue ?? this.issue ?? '',
      photos: photos ?? this.photos ?? const [],
      status: status ?? this.status ?? RepairStatus.pending,
      createdAt: createdAt ?? this.createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isPaid: isPaid ?? this.isPaid ?? false,
      notes: notes ?? this.notes ?? const [],
      tasks: tasks ?? this.tasks ?? const [],
      devicePassword: devicePassword ?? this.devicePassword,
      accessories: accessories ?? this.accessories ?? const [],
      visualState: visualState ?? this.visualState ?? const [],
    );
  }
}

class RepairNote {
  final String id;
  final String authorId;
  final String authorName;
  final String authorType; // 'technician', 'client', 'point_relais', 'admin'
  final String content;
  final DateTime createdAt;
  final bool isPrivate; // Si true, visible uniquement par les techniciens

  RepairNote({
    String? id,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    required this.content,
    DateTime? createdAt,
    this.isPrivate = false,
  }) : 
    this.id = id != null && RepairModel._isValidUuid(id) ? id : const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now();

  static bool _isValidUuid(String? value) {
    if (value == null) return false;
    final uuidRegExp = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegExp.hasMatch(value);
  }

  factory RepairNote.fromJson(Map<String, dynamic> json) {
    return RepairNote(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorType: json['authorType'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPrivate: json['isPrivate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      
      'authorId': authorId,
      'authorName': authorName,
      'authorType': authorType,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }
}

class RepairTask {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final double? price;
  final DateTime? completedAt;

  RepairTask({
    String? id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.price,
    this.completedAt,
  }) : this.id = id ?? const Uuid().v4();

  factory RepairTask.fromJson(Map<String, dynamic> json) {
    return RepairTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      price: json['price'] as double?,
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'price': price,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  RepairTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    double? price,
    DateTime? completedAt,
  }) {
    return RepairTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      price: price ?? this.price,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
