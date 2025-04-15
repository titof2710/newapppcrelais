-- Fonction pour vérifier si une colonne existe dans une table
CREATE OR REPLACE FUNCTION column_exists(table_name text, column_name text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  column_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = $1
    AND column_name = $2
  ) INTO column_exists;
  
  RETURN column_exists;
END;
$$;

-- Fonction pour ajouter une colonne à une table si elle n'existe pas déjà
CREATE OR REPLACE FUNCTION add_column_if_not_exists(table_name text, column_name text, column_type text)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
  column_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = $1
    AND column_name = $2
  ) INTO column_exists;
  
  IF NOT column_exists THEN
    EXECUTE format('ALTER TABLE %I ADD COLUMN %I %s', $1, $2, $3);
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
$$;
