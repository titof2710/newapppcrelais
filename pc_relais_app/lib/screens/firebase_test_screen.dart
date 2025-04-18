import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/firebase_service.dart';
import '../services/supabase_service.dart';
import '../services/supabase_config.dart';
import '../services/supabase_helper.dart';

/// Écran de test pour vérifier que Firebase et Supabase fonctionnent correctement sur le web
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();
  String _testResult = '';
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'État de Firebase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Initialisé: ${_firebaseService.isInitialized}',
                      style: TextStyle(
                        color: _firebaseService.isInitialized ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Mode démo: ${_firebaseService.isDemo}',
                      style: TextStyle(
                        color: _firebaseService.isDemo ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testAuthentication,
              child: const Text('Tester l\'authentification anonyme'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSupabase,
              child: const Text('Tester Supabase Database'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSupabaseStorage,
              child: const Text('Tester Supabase Storage'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_testResult.isNotEmpty)
              Card(
                color: _testResult.contains('Erreur') ? Colors.red.shade100 : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _testResult.contains('Erreur') ? 'Erreur' : 'Succès',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _testResult.contains('Erreur') ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_testResult),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _testResult = 'Authentification réussie! UID: ${userCredential.user?.uid}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Erreur d\'authentification: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSupabase() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final response = await _supabaseService.client
          .from('test_web')
          .insert({
            'timestamp': DateTime.now().toString(),
            'platform': 'web',
            'test': 'Supabase test',
          })
          ;
      
      if (SupabaseHelper.hasError(response)) {
        throw Exception(SupabaseHelper.getErrorMessage(response));
      }
      
      setState(() {
        _testResult = 'Document Supabase créé avec succès!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Erreur Supabase: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSupabaseStorage() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final fileName = 'test_web_${DateTime.now().millisecondsSinceEpoch}.txt';
      final fileContent = 'Test depuis Flutter Web - ${DateTime.now()}';
      final bytes = Uint8List.fromList(fileContent.codeUnits);
      
      // Upload du fichier
      String path;
      try {
        path = await _supabaseService.client
            .storage
            .from('test_bucket')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'text/plain'),
            );
            
        if (path.isEmpty) {
          throw Exception('Chemin de fichier vide retourné par Supabase');
        }
      } catch (storageError) {
        throw Exception('Erreur lors de l\'upload du fichier: $storageError');
      }
      
      // Récupération de l'URL publique
      final downloadUrl = _supabaseService.client
          .storage
          .from('test_bucket')
          .getPublicUrl(fileName);
      
      setState(() {
        _testResult = 'Fichier Supabase Storage créé avec succès! URL: $downloadUrl';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Erreur Supabase Storage: $e';
        _isLoading = false;
      });
    }
  }
}
