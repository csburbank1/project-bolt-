/*
  # Add Admin System and School Management

  1. New Tables
    - schools: Stores school information
    - school_admins: Links admins to schools
    - school_domains: Allowed email domains for each school

  2. Changes
    - Add school_id to profiles table
    - Add admin role type
    - Add functions for school management

  3. Security
    - RLS policies for school-based access
    - Admin-specific policies
*/

-- Create schools table
CREATE TABLE IF NOT EXISTS schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
  settings JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create school domains table
CREATE TABLE IF NOT EXISTS school_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  domain TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(school_id, domain)
);

-- Create school admins table
CREATE TABLE IF NOT EXISTS school_admins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'school_admin' CHECK (role IN ('super_admin', 'school_admin')),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, school_id)
);

-- Add school_id to profiles
ALTER TABLE profiles 
ADD COLUMN school_id UUID REFERENCES schools(id);

-- Update user_roles to include admin roles
ALTER TABLE user_roles
DROP CONSTRAINT IF EXISTS user_roles_role_check,
ADD CONSTRAINT user_roles_role_check 
CHECK (role IN ('student', 'staff', 'admin', 'super_admin'));

-- Create indexes
CREATE INDEX idx_profiles_school_id ON profiles(school_id);
CREATE INDEX idx_school_domains_domain ON school_domains(domain);
CREATE INDEX idx_school_admins_user ON school_admins(user_id);
CREATE INDEX idx_school_admins_school ON school_admins(school_id);

-- Enable RLS
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_admins ENABLE ROW LEVEL SECURITY;

-- Create admin management function
CREATE OR REPLACE FUNCTION manage_school_admin(
  p_user_id UUID,
  p_school_id UUID,
  p_role TEXT DEFAULT 'school_admin'
) RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result json;
BEGIN
  -- Validate role
  IF p_role NOT IN ('super_admin', 'school_admin') THEN
    RAISE EXCEPTION 'Invalid admin role';
  END IF;

  -- Insert or update admin
  INSERT INTO school_admins (user_id, school_id, role)
  VALUES (p_user_id, p_school_id, p_role)
  ON CONFLICT (user_id, school_id) 
  DO UPDATE SET role = p_role
  RETURNING json_build_object(
    'id', id,
    'user_id', user_id,
    'school_id', school_id,
    'role', role
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- Create school management function
CREATE OR REPLACE FUNCTION create_school(
  p_name TEXT,
  p_code TEXT,
  p_domains TEXT[]
) RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_school_id UUID;
  v_result json;
BEGIN
  -- Create school
  INSERT INTO schools (name, code)
  VALUES (p_name, p_code)
  RETURNING id INTO v_school_id;

  -- Add domains
  INSERT INTO school_domains (school_id, domain, is_primary)
  SELECT v_school_id, domain, CASE WHEN ordinality = 1 THEN true ELSE false END
  FROM unnest(p_domains) WITH ORDINALITY AS t(domain);

  -- Return result
  SELECT json_build_object(
    'school', s,
    'domains', json_agg(d)
  ) INTO v_result
  FROM schools s
  LEFT JOIN school_domains d ON d.school_id = s.id
  WHERE s.id = v_school_id
  GROUP BY s.id;

  RETURN v_result;
END;
$$;

-- Create policies

-- Schools
CREATE POLICY "Super admins can manage schools"
  ON schools FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_admins
      WHERE user_id = auth.uid()
      AND role = 'super_admin'
    )
  );

CREATE POLICY "School admins can view their school"
  ON schools FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_admins
      WHERE user_id = auth.uid()
      AND school_id = schools.id
    )
  );

-- School Domains
CREATE POLICY "Admins can manage school domains"
  ON school_domains FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_admins
      WHERE user_id = auth.uid()
      AND (role = 'super_admin' OR school_id = school_domains.school_id)
    )
  );

-- School Admins
CREATE POLICY "Super admins can manage all admins"
  ON school_admins FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_admins
      WHERE user_id = auth.uid()
      AND role = 'super_admin'
    )
  );

CREATE POLICY "School admins can view their school's admins"
  ON school_admins FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM school_admins a
      WHERE a.user_id = auth.uid()
      AND a.school_id = school_admins.school_id
    )
  );

-- Insert initial super admin (replace with your admin email)
INSERT INTO schools (id, name, code) 
VALUES ('00000000-0000-0000-0000-000000000001', 'System', 'SYSTEM')
ON CONFLICT (code) DO NOTHING;

-- Create a function to validate school email domains
CREATE OR REPLACE FUNCTION validate_school_email() 
RETURNS trigger AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM school_domains
    WHERE domain = split_part(NEW.email, '@', 2)
  ) THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'Invalid school email domain';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for email validation
CREATE TRIGGER validate_school_email_trigger
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_school_email();