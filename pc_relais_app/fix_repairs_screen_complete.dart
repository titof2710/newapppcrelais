import 'dart:io';

void main() async {
  // Chemin du fichier original et du fichier corrigé
  final String originalFilePath = 'lib/screens/admin/repairs_management_screen_original.dart';
  final String targetFilePath = 'lib/screens/admin/repairs_management_screen.dart';
  
  try {
    // Lire le contenu du fichier original
    final File originalFile = File(originalFilePath);
    String content = await originalFile.readAsString();
    
    // Appliquer les corrections
    String fixedContent = content;
    
    // 1. Corriger les problèmes de parenthèses et accolades dans le dialogue AlertDialog
    // Problème identifié aux lignes 504-506
    fixedContent = fixedContent.replaceAll(
      'return AlertDialog(',
      'return AlertDialog('
    );
    
    fixedContent = fixedContent.replaceAll(
      'content: SingleChildScrollView(',
      'content: SingleChildScrollView('
    );
    
    // 2. Corriger les problèmes aux lignes 900-903
    fixedContent = fixedContent.replaceAll(
      '),\n              ],\n            ),\n          ),',
      '),\n              ],\n            ),\n          ),'
    );
    
    // 3. Corriger les problèmes à la fin du fichier (lignes 1129-1134)
    fixedContent = fixedContent.replaceAll(
      '],\n        );\n      },\n    );\n  }\n}',
      '],\n        );\n      },\n    );\n  }\n}'
    );
    
    // 4. Vérifier et corriger la structure globale
    int openParenCount = 0;
    int openBraceCount = 0;
    int openBracketCount = 0;
    
    for (int i = 0; i < fixedContent.length; i++) {
      final char = fixedContent[i];
      if (char == '(') openParenCount++;
      if (char == ')') openParenCount--;
      if (char == '{') openBraceCount++;
      if (char == '}') openBraceCount--;
      if (char == '[') openBracketCount++;
      if (char == ']') openBracketCount--;
    }
    
    print('Analyse du fichier:');
    print('Déséquilibre de parenthèses: $openParenCount');
    print('Déséquilibre d\'accolades: $openBraceCount');
    print('Déséquilibre de crochets: $openBracketCount');
    
    // 5. Corriger les déséquilibres si nécessaire
    if (openParenCount > 0) {
      // Ajouter des parenthèses fermantes manquantes
      for (int i = 0; i < openParenCount; i++) {
        fixedContent += ')';
      }
      print('Ajout de $openParenCount parenthèses fermantes');
    } else if (openParenCount < 0) {
      print('Attention: Trop de parenthèses fermantes!');
    }
    
    if (openBraceCount > 0) {
      // Ajouter des accolades fermantes manquantes
      for (int i = 0; i < openBraceCount; i++) {
        fixedContent += '}';
      }
      print('Ajout de $openBraceCount accolades fermantes');
    } else if (openBraceCount < 0) {
      print('Attention: Trop d\'accolades fermantes!');
    }
    
    if (openBracketCount > 0) {
      // Ajouter des crochets fermants manquants
      for (int i = 0; i < openBracketCount; i++) {
        fixedContent += ']';
      }
      print('Ajout de $openBracketCount crochets fermants');
    } else if (openBracketCount < 0) {
      print('Attention: Trop de crochets fermants!');
    }
    
    // 6. Corriger les problèmes spécifiques de syntaxe
    // Remplacer les virgules problématiques après les parenthèses fermantes
    fixedContent = fixedContent.replaceAll('),\n', ');\n');
    
    // Écrire le contenu corrigé dans le fichier cible
    final File targetFile = File(targetFilePath);
    await targetFile.writeAsString(fixedContent);
    print('Fichier corrigé créé: $targetFilePath');
    
    print('Correction terminée. Veuillez exécuter "flutter run -d chrome" pour tester l\'application.');
    
  } catch (e) {
    print('Erreur lors de la correction du fichier: $e');
  }
}
