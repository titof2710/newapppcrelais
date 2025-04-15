-- Activer l'extension uuid-ossp pour générer des UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des utilisateurs
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
  id TEXT PRIMARY KEY, -- Changé de UUID à TEXT pour accepter les IDs Firebase
  email TEXT UNIQUE NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT,
  user_type TEXT NOT NULL CHECK (user_type IN ('client', 'point_relais', 'admin', 'technicien')),
  profile_image_url TEXT,
  repair_ids TEXT[] DEFAULT '{}'::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des points relais (informations supplémentaires)
DROP TABLE IF EXISTS point_relais_details CASCADE;
CREATE TABLE point_relais_details (
  id TEXT PRIMARY KEY REFERENCES users(id), -- Changé de UUID à TEXT
  shop_name TEXT NOT NULL,
  shop_address TEXT NOT NULL,
  opening_hours TEXT[] NOT NULL,
  storage_capacity INTEGER NOT NULL,
  current_storage_used INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des techniciens (informations supplémentaires)
DROP TABLE IF EXISTS technicien_details CASCADE;
CREATE TABLE technicien_details (
  id TEXT PRIMARY KEY REFERENCES users(id), -- Changé de UUID à TEXT
  speciality TEXT[] DEFAULT '{}'::TEXT[],
  experience_years INTEGER DEFAULT 0,
  certifications TEXT[] DEFAULT '{}'::TEXT[],
  assigned_repairs TEXT[] DEFAULT '{}'::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des administrateurs (informations supplémentaires)
DROP TABLE IF EXISTS admin_details CASCADE;
CREATE TABLE admin_details (
  id TEXT PRIMARY KEY REFERENCES users(id), -- Changé de UUID à TEXT
  permissions TEXT[] DEFAULT '{}'::TEXT[],
  role TEXT DEFAULT 'admin',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des réparations
DROP TABLE IF EXISTS repairs CASCADE;
CREATE TABLE repairs (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  client_id TEXT REFERENCES users(id), -- Changé de UUID à TEXT
  point_relais_id TEXT REFERENCES users(id), -- Changé de UUID à TEXT
  technicien_id TEXT REFERENCES users(id), -- Référence au technicien assigné
  device_type TEXT NOT NULL,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  serial_number TEXT,
  issue TEXT NOT NULL,
  photos TEXT[] DEFAULT '{}'::TEXT[],
  status TEXT NOT NULL DEFAULT 'waitingForDropOff',
  estimated_price DECIMAL(10, 2),
  is_paid BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  estimated_completion_date TIMESTAMP WITH TIME ZONE
);

-- Table des notes de réparation
DROP TABLE IF EXISTS repair_notes CASCADE;
CREATE TABLE repair_notes (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  repair_id TEXT REFERENCES repairs(id), -- Changé de UUID à TEXT
  author_id TEXT REFERENCES users(id), -- Changé de UUID à TEXT
  author_name TEXT NOT NULL,
  author_type TEXT NOT NULL,
  content TEXT NOT NULL,
  is_private BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des tâches de réparation
DROP TABLE IF EXISTS repair_tasks CASCADE;
CREATE TABLE repair_tasks (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  repair_id TEXT REFERENCES repairs(id), -- Changé de UUID à TEXT
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  price DECIMAL(10, 2),
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des conversations
DROP TABLE IF EXISTS conversations CASCADE;
CREATE TABLE conversations (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  repair_id TEXT REFERENCES repairs(id), -- Changé de UUID à TEXT
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des messages
DROP TABLE IF EXISTS messages CASCADE;
CREATE TABLE messages (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  conversation_id TEXT REFERENCES conversations(id), -- Changé de UUID à TEXT
  sender_id TEXT REFERENCES users(id), -- Changé de UUID à TEXT
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des produits
DROP TABLE IF EXISTS products CASCADE;
CREATE TABLE products (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  category TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des commandes
DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  client_id TEXT REFERENCES users(id), -- Changé de UUID à TEXT
  total_amount DECIMAL(10, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des éléments de commande
DROP TABLE IF EXISTS order_items CASCADE;
CREATE TABLE order_items (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT, -- Changé de UUID à TEXT
  order_id TEXT REFERENCES orders(id), -- Changé de UUID à TEXT
  product_id TEXT REFERENCES products(id), -- Changé de UUID à TEXT
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer des triggers pour mettre à jour automatiquement les champs updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Appliquer le trigger à toutes les tables avec un champ updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_point_relais_details_updated_at BEFORE UPDATE ON point_relais_details
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_technicien_details_updated_at BEFORE UPDATE ON technicien_details
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_details_updated_at BEFORE UPDATE ON admin_details
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_repairs_updated_at BEFORE UPDATE ON repairs
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_repair_tasks_updated_at BEFORE UPDATE ON repair_tasks
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
