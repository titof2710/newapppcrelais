import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Pour stocker le token FCM
  String? _token;
  String? get token => _token;

  // Initialiser le service de notification
  Future<void> initialize() async {
    // Demander les permissions
    await _requestPermissions();
    
    // Configurer les notifications locales
    await _setupLocalNotifications();
    
    // Configurer les gestionnaires de messages FCM
    _setupFirebaseMessaging();
    
    // Obtenir le token FCM
    await _getToken();
  }

  // Demander les permissions de notification
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Statut des autorisations de notification: ${settings.authorizationStatus}');
  }

  // Configurer les notifications locales
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Gérer le clic sur la notification
        print('Notification cliquée: ${response.payload}');
      },
    );

    // Créer le canal de notification Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notifications importantes',
      description: 'Canal pour les notifications importantes',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Configurer les gestionnaires de messages FCM
  void _setupFirebaseMessaging() {
    // Gestionnaire pour les messages reçus en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu en premier plan: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    // Gestionnaire pour les messages ouverts
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message ouvert: ${message.notification?.title}');
      // Naviguer vers l'écran approprié en fonction du message
    });
  }

  // Obtenir le token FCM
  Future<void> _getToken() async {
    _token = await _firebaseMessaging.getToken();
    print('Token FCM: $_token');
    
    // Écouter les changements de token
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _token = token;
      print('Token FCM mis à jour: $_token');
      // Mettre à jour le token dans la base de données
    });
  }

  // Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification == null) return;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'Notifications importantes',
      channelDescription: 'Canal pour les notifications importantes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformDetails,
      payload: message.data['screen'],
    );
  }

  // S'abonner à un sujet (topic)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Abonné au sujet: $topic');
  }

  // Se désabonner d'un sujet (topic)
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Désabonné du sujet: $topic');
  }
}
