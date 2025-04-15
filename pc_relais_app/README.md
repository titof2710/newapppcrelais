# PC Relais - Application Mobile

Application mobile pour le service PC Relais - réparation informatique et vente de matériel reconditionné via des points relais partenaires.

## Fonctionnalités

### Interface Client
- Suivi des réparations en temps réel
- Historique des interventions
- Paiement en ligne
- Prise de rendez-vous
- Chat avec le technicien
- Localisation des points relais à proximité

### Interface Buraliste
- Enregistrement des dépôts et retraits
- Notifications des arrivées imminentes
- Gestion de l'espace de stockage
- Communication avec l'atelier
- Scan des appareils

## Installation

### Prérequis
- Flutter SDK (version 3.7.0 ou supérieure)
- Dart SDK (version 3.0.0 ou supérieure)
- Android Studio / VS Code avec les extensions Flutter
- Un compte Firebase

### Configuration de Firebase

1. Créez un projet Firebase sur la [console Firebase](https://console.firebase.google.com/)
2. Ajoutez une application Android et iOS à votre projet Firebase
3. Téléchargez et placez les fichiers de configuration :
   - Pour Android : `google-services.json` dans le dossier `android/app`
   - Pour iOS : `GoogleService-Info.plist` dans le dossier `ios/Runner`
4. Activez les services suivants dans la console Firebase :
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Messaging

### Installation des dépendances

```bash
flutter pub get
```

### Lancement de l'application

```bash
flutter run
```

## Architecture du projet

- `lib/models/` : Modèles de données (utilisateurs, réparations, etc.)
- `lib/screens/` : Écrans de l'application (client, point relais, technicien et administrateur)
- `lib/services/` : Services (authentification, réparations, chat)
- `lib/navigation/` : Configuration de la navigation
- `lib/theme/` : Thèmes et styles de l'application
- `lib/widgets/` : Widgets réutilisables
- `lib/utils/` : Utilitaires et helpers

## Déploiement

### Android

```bash
flutter build apk --release
```

Le fichier APK sera généré dans `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Ouvrez le dossier `ios/` dans Xcode et déployez l'application sur l'App Store.

## Contribution

Pour contribuer au projet, veuillez suivre ces étapes :

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité
3. Commitez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence propriétaire. Tous droits réservés.
