import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialisation de Firebase
  final Future<void> _initialization = FirebaseService().initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Relais Web',
      theme: AppTheme.clientTheme,
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Vérification des erreurs
          if (snapshot.hasError) {
            return const FirebaseErrorScreen();
          }

          // Une fois Firebase initialisé
          if (snapshot.connectionState == ConnectionState.done) {
            return const FirebaseSuccessScreen();
          }

          // Pendant le chargement
          return const LoadingScreen();
        },
      ),
    );
  }
}

// Écran de chargement
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initialisation de Firebase...'),
          ],
        ),
      ),
    );
  }
}

// Écran en cas d'erreur
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur Firebase'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur d\'initialisation de Firebase',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vérifiez votre configuration et réessayez.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Recharger l'application
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// Écran en cas de succès
class FirebaseSuccessScreen extends StatelessWidget {
  const FirebaseSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PC Relais Web - Test Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Firebase initialisé avec succès !',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Tester l'authentification Firebase
                  final userCredential = await FirebaseAuth.instance.signInAnonymously();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Authentification réussie: ${userCredential.user?.uid}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur d\'authentification: $e')),
                  );
                }
              },
              child: const Text('Tester l\'authentification'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Tester Firestore
                  final testDoc = await FirebaseFirestore.instance.collection('test').add({
                    'timestamp': DateTime.now().toString(),
                    'message': 'Test depuis Flutter Web',
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Document Firestore créé: ${testDoc.id}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur Firestore: $e')),
                  );
                }
              },
              child: const Text('Tester Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
