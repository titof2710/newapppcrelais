// Configuration pour Supabase
class SupabaseConfig {
  // URL de votre projet Supabase
  static const String supabaseUrl = 'https://tltexlhwygkssvxtmszk.supabase.co';
  
  // Clé API publique de votre projet Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsdGV4bGh3eWdrc3N2eHRtc3prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMjQ1NjYsImV4cCI6MjA1OTcwMDU2Nn0.qZgAxSTBIxysFFekqvRYm5kn0furM5CmbAsqpik7-j8';
  
  // Collections (tables) Supabase
  static const String usersTable = 'users';
  static const String repairsTable = 'repairs';
  static const String messagesTable = 'messages';
  static const String conversationsTable = 'conversations';
  static const String productsTable = 'products';
  static const String ordersTable = 'orders';
  static const String pointRelaisDetailsTable = 'point_relais_details';
  static const String technicienDetailsTable = 'technicien_details';
  static const String adminDetailsTable = 'admin_details';
  
  // Structure des tables
  // La table users contient les informations sur les utilisateurs (clients, points relais, techniciens et administrateurs)
  // La table repairs contient les informations sur les réparations
  // La table messages contient les messages des conversations
  // La table conversations contient les métadonnées des conversations
  // La table products contient les produits disponibles à la vente
  // La table orders contient les commandes des clients
  // La table point_relais_details contient les informations supplémentaires des points relais
  // La table technicien_details contient les informations supplémentaires des techniciens
  // La table admin_details contient les informations supplémentaires des administrateurs
}
