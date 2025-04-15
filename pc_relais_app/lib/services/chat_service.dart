import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_config.dart';
import 'supabase_service.dart';
import 'supabase_helper.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType; // 'client', 'point_relais', 'technician'
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final List<String> attachments; // URLs des pièces jointes (images, etc.)

  ChatMessage({
    String? id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
    this.attachments = const [],
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderType: json['senderType'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachments': attachments,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderType,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    List<String>? attachments,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ChatConversation {
  final String id;
  final String repairId; // ID de la réparation associée
  final List<String> participantIds; // IDs des participants
  final Map<String, String> participantNames; // Noms des participants
  final Map<String, String> participantTypes; // Types des participants
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts; // Nombre de messages non lus par participant

  ChatConversation({
    String? id,
    required this.repairId,
    required this.participantIds,
    required this.participantNames,
    required this.participantTypes,
    DateTime? createdAt,
    this.lastMessageAt,
    Map<String, int>? unreadCounts,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.unreadCounts = unreadCounts ?? {};

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      repairId: json['repairId'] as String,
      participantIds: List<String>.from(json['participantIds']),
      participantNames: Map<String, String>.from(json['participantNames']),
      participantTypes: Map<String, String>.from(json['participantTypes']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMessageAt: json['lastMessageAt'] != null 
        ? DateTime.parse(json['lastMessageAt'] as String) 
        : null,
      unreadCounts: json['unreadCounts'] != null 
        ? Map<String, int>.from(json['unreadCounts']) 
        : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repairId': repairId,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantTypes': participantTypes,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'unreadCounts': unreadCounts,
    };
  }
}

class ChatService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = Uuid();

  // Créer une nouvelle conversation
  Future<ChatConversation> createConversation({
    required String repairId,
    required List<String> participantIds,
    required Map<String, String> participantNames,
    required Map<String, String> participantTypes,
  }) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'utilisateur actuel est un participant
      if (!participantIds.contains(currentUser.uid)) {
        throw Exception('Vous n\'êtes pas autorisé à créer cette conversation');
      }

      final ChatConversation conversation = ChatConversation(
        repairId: repairId,
        participantIds: participantIds,
        participantNames: participantNames,
        participantTypes: participantTypes,
      );

      // Ajouter la conversation à Supabase
      final response = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .insert(conversation.toJson())
          .execute();
          
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la création de la conversation: ${SupabaseHelper.getErrorMessage(response)}');
      }

      return conversation;
    } catch (e) {
      throw Exception('Erreur lors de la création de la conversation: $e');
    }
  }

  // Envoyer un message dans une conversation
  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'expéditeur est bien l'utilisateur actuel
      if (message.senderId != currentUser.uid) {
        throw Exception('Vous n\'êtes pas autorisé à envoyer ce message');
      }

      // Ajouter le message à Supabase
      final messageData = message.toJson();
      messageData['conversationId'] = conversationId; // Ajouter l'ID de la conversation
      
      final msgResponse = await _supabaseService.client
          .from(SupabaseConfig.messagesTable)
          .insert(messageData)
          .execute();
          
      if (SupabaseHelper.hasError(msgResponse)) {
        throw Exception('Erreur lors de l\'envoi du message: ${SupabaseHelper.getErrorMessage(msgResponse)}');
      }

      // Récupérer la conversation
      final getConvResponse = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .eq('id', conversationId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(getConvResponse)) {
        throw Exception('Conversation introuvable: ${SupabaseHelper.getErrorMessage(getConvResponse)}');
      }

      final ChatConversation conversation = ChatConversation.fromJson(getConvResponse.data as Map<String, dynamic>);
      
      // Mettre à jour les compteurs de messages non lus pour tous les participants sauf l'expéditeur
      final Map<String, int> updatedUnreadCounts = Map.from(conversation.unreadCounts);
      for (final participantId in conversation.participantIds) {
        if (participantId != message.senderId) {
          updatedUnreadCounts[participantId] = (updatedUnreadCounts[participantId] ?? 0) + 1;
        }
      }

      // Mettre à jour la conversation
      final updateConvResponse = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .update({
            'lastMessageAt': DateTime.now().toIso8601String(),
            'unreadCounts': updatedUnreadCounts,
          })
          .eq('id', conversationId)
          .execute();
          
      if (SupabaseHelper.hasError(updateConvResponse)) {
        throw Exception('Erreur lors de la mise à jour de la conversation: ${SupabaseHelper.getErrorMessage(updateConvResponse)}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Marquer les messages comme lus pour un utilisateur
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer la conversation
      final getConvResponse = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .eq('id', conversationId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(getConvResponse)) {
        throw Exception('Conversation introuvable: ${SupabaseHelper.getErrorMessage(getConvResponse)}');
      }

      final ChatConversation conversation = ChatConversation.fromJson(getConvResponse.data as Map<String, dynamic>);
      
      // Vérifier que l'utilisateur est un participant
      if (!conversation.participantIds.contains(currentUser.uid)) {
        throw Exception('Vous n\'êtes pas autorisé à accéder à cette conversation');
      }

      // Mettre à jour le compteur de messages non lus pour l'utilisateur actuel
      final Map<String, int> updatedUnreadCounts = Map.from(conversation.unreadCounts);
      updatedUnreadCounts[currentUser.uid] = 0;

      // Mettre à jour la conversation
      final updateConvResponse = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .update({
            'unreadCounts': updatedUnreadCounts,
          })
          .eq('id', conversationId)
          .execute();
          
      if (SupabaseHelper.hasError(updateConvResponse)) {
        throw Exception('Erreur lors de la mise à jour de la conversation: ${SupabaseHelper.getErrorMessage(updateConvResponse)}');
      }

      // Marquer tous les messages non lus comme lus
      final updateMsgResponse = await _supabaseService.client
          .from(SupabaseConfig.messagesTable)
          .update({'isRead': true})
          .eq('conversationId', conversationId)
          .eq('isRead', false)
          .neq('senderId', currentUser.uid)
          .execute();
      
      if (SupabaseHelper.hasError(updateMsgResponse)) {
        throw Exception('Erreur lors de la mise à jour des messages: ${SupabaseHelper.getErrorMessage(updateMsgResponse)}');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage des messages comme lus: $e');
    }
  }

  // Obtenir une conversation par son ID
  Future<ChatConversation> getConversationById(String conversationId) async {
    try {
      final response = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .eq('id', conversationId)
          .single()
          .execute();
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception('Conversation introuvable: ${SupabaseHelper.getErrorMessage(response)}');
      }

      return ChatConversation.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  // Obtenir toutes les conversations d'un utilisateur
  Future<List<ChatConversation>> getUserConversations() async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Note: Supabase ne supporte pas directement la recherche dans les tableaux comme Firestore
      // Il faudrait créer une fonction côté serveur ou utiliser une structure de données différente
      // Pour simplifier, nous allons récupérer toutes les conversations et filtrer côté client
      final response = await _supabaseService.client
          .from(SupabaseConfig.conversationsTable)
          .select()
          .order('lastMessageAt', ascending: false)
          .execute();

      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des conversations: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => ChatConversation.fromJson(item as Map<String, dynamic>))
          .where((conversation) => conversation.participantIds.contains(currentUser.uid))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des conversations: $e');
    }
  }

  // Obtenir tous les messages d'une conversation
  Future<List<ChatMessage>> getConversationMessages(String conversationId) async {
    try {
      final firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'utilisateur est un participant de la conversation
      final ChatConversation conversation = await getConversationById(conversationId);
      
      if (!conversation.participantIds.contains(currentUser.uid)) {
        throw Exception('Vous n\'êtes pas autorisé à accéder à cette conversation');
      }

      final response = await _supabaseService.client
          .from(SupabaseConfig.messagesTable)
          .select()
          .eq('conversationId', conversationId)
          .order('timestamp', ascending: false)
          .execute();

      if (SupabaseHelper.hasError(response)) {
        throw Exception('Erreur lors de la récupération des messages: ${SupabaseHelper.getErrorMessage(response)}');
      }

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  // Obtenir un flux (stream) de mises à jour pour une conversation spécifique
  Stream<ChatConversation> getConversationStream(String conversationId) {
    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    return Stream.periodic(const Duration(seconds: 3)).asyncMap((_) async {
      return await getConversationById(conversationId);
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.conversationsTable)
    //     .stream(['id'])
    //     .eq('id', conversationId)
    //     .execute()
    //     .map((data) {
    //       if (data.isEmpty) throw Exception('Conversation introuvable');
    //       return ChatConversation.fromJson(data.first as Map<String, dynamic>);
    //     });
  }

  // Obtenir un flux (stream) de messages pour une conversation spécifique
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      return await getConversationMessages(conversationId);
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.messagesTable)
    //     .stream(['id'])
    //     .eq('conversationId', conversationId)
    //     .order('timestamp')
    //     .execute()
    //     .map((data) => data
    //         .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
    //         .toList());
  }

  // Obtenir un flux (stream) de toutes les conversations d'un utilisateur
  Stream<List<ChatConversation>> getUserConversationsStream() {
    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Retourner un stream vide si l'utilisateur n'est pas connecté
      return Stream.value([]);
    }

    // Avec Supabase, nous devons simuler un stream en utilisant des requêtes répétées
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getUserConversations();
    });
    
    // Alternative avec Supabase Realtime (nécessite une configuration côté serveur)
    // return _supabaseService.client
    //     .from(SupabaseConfig.conversationsTable)
    //     .stream(['id'])
    //     .order('lastMessageAt', ascending: false)
    //     .execute()
    //     .map((data) => data
    //         .map((item) => ChatConversation.fromJson(item as Map<String, dynamic>))
    //         .where((conversation) => conversation.participantIds.contains(currentUser.uid))
    //         .toList());
  }
}
