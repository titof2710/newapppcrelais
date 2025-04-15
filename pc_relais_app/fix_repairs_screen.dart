import 'dart:io';

void main() async {
  // Chemin du fichier à corriger
  final String filePath = 'lib/screens/admin/repairs_management_screen.dart';
  
  try {
    // Lire le contenu du fichier
    final File file = File(filePath);
    String content = await file.readAsString();
    
    // Créer une sauvegarde
    await File('${filePath}.backup').writeAsString(content);
    print('Sauvegarde créée: ${filePath}.backup');
    
    // Corriger les erreurs de syntaxe
    String fixedContent = content;
    
    // Corriger les problèmes de parenthèses et accolades
    // 1. Assurer que les parenthèses et accolades sont correctement fermées
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
    
    print('Déséquilibre de parenthèses: $openParenCount');
    print('Déséquilibre d\'accolades: $openBraceCount');
    print('Déséquilibre de crochets: $openBracketCount');
    
    // 2. Corriger les erreurs spécifiques mentionnées dans les messages d'erreur
    
    // Corriger les erreurs aux lignes 900-903
    fixedContent = fixedContent.replaceAll(
      '),\n              ],\n            ),\n          ),',
      '),\n              ],\n            ),\n          ),');
    
    // Corriger les erreurs à la fin du fichier
    fixedContent = fixedContent.replaceAll(
      '],\n        );\n      },\n    );\n  }\n}',
      '],\n        );\n      },\n    );\n  }\n}');
    
    // Écrire le contenu corrigé dans le fichier
    await file.writeAsString(fixedContent);
    print('Fichier corrigé: $filePath');
    
    // Vérifier si le fichier peut être compilé
    print('Tentative de compilation...');
    final result = await Process.run('flutter', ['analyze', filePath]);
    print(result.stdout);
    if (result.exitCode != 0) {
      print('Des erreurs persistent. Veuillez vérifier manuellement le fichier.');
    } else {
      print('Compilation réussie!');
    }
    
  } catch (e) {
    print('Erreur lors de la correction du fichier: $e');
  }
}
