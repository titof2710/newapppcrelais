class Validators {
  // Validation de champ non vide
  static String? notEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  // Alias pour email
  static String? email(String? value) {
    return validateEmail(value);
  }

  // Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  // Validation de mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  // Validation de confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Validation de nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  // Validation de numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    final phoneRegex = RegExp(r'^(?:\+33|0)[1-9](?:[\s.-]?[0-9]{2}){4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    return null;
  }

  // Validation d'adresse
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une adresse';
    }
    if (value.length < 10) {
      return 'Veuillez entrer une adresse complète';
    }
    return null;
  }

  // Validation de nom de commerce
  static String? validateShopName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le nom de votre commerce';
    }
    return null;
  }
}
