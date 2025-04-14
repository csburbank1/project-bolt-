/*
  # Initial Schema Setup for MoodBuddy

  1. New Tables
    - profiles
      - User profile information
      - Includes role-specific fields
    - behavior_forms
      - Templates for behavior tracking
    - behavior_records
      - Individual behavior tracking entries
    - behavior_goals
      - Student behavior goals
    - behavior_comments
      - Staff comments on student behavior
    - achievements
      - Available achievements
    - user_achievements
      - User-earned achievements

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated access
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('student', 'staff')) NOT NULL,
  grade_level TEXT,
  age_group TEXT CHECK (age_group IN ('kids', 'teens', 'adults')),
  specialization TEXT,
  avatar_url TEXT,
  theme_preference TEXT DEFAULT 'light',
  profile_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create behavior forms table
CREATE TABLE IF NOT EXISTS behavior_forms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  categories JSONB NOT NULL,
  rating_scale JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create behavior records table
CREATE TABLE IF NOT EXISTS behavior_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id UUID REFERENCES behavior_forms(id) NOT NULL,
  student_id UUID REFERENCES profiles(id) NOT NULL,
  staff_id UUID REFERENCES profiles(id) NOT NULL,
  date DATE NOT NULL,
  ratings JSONB NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create behavior goals table
CREATE TABLE IF NOT EXISTS behavior_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) NOT NULL,
  staff_id UUID REFERENCES profiles(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  target_date DATE,
  status TEXT CHECK (status IN ('active', 'completed', 'archived')) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create behavior comments table
CREATE TABLE IF NOT EXISTS behavior_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id) NOT NULL,
  staff_id UUID REFERENCES profiles(id) NOT NULL,
  comment TEXT NOT NULL,
  context TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create achievements table
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  criteria JSONB NOT NULL,
  points INTEGER DEFAULT 0,
  badge_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create user achievements table
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  achievement_id UUID REFERENCES achievements(id) NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Profiles
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Behavior Forms
CREATE POLICY "Staff can manage behavior forms"
  ON behavior_forms FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'staff'
  ));

CREATE POLICY "Students can view active behavior forms"
  ON behavior_forms FOR SELECT
  TO authenticated
  USING (
    is_active = true AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'student'
    )
  );

-- Behavior Records
CREATE POLICY "Staff can manage all behavior records"
  ON behavior_records FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'staff'
  ));

CREATE POLICY "Students can view own behavior records"
  ON behavior_records FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Behavior Goals
CREATE POLICY "Staff can manage behavior goals"
  ON behavior_goals FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'staff'
  ));

CREATE POLICY "Students can view own goals"
  ON behavior_goals FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Behavior Comments
CREATE POLICY "Staff can manage behavior comments"
  ON behavior_comments FOR ALL
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'staff'
  ));

CREATE POLICY "Students can view comments about themselves"
  ON behavior_comments FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Achievements
CREATE POLICY "Everyone can view achievements"
  ON achievements FOR SELECT
  TO authenticated
  USING (true);

-- User Achievements
CREATE POLICY "Users can view own achievements"
  ON user_achievements FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_behavior_records_student_id ON behavior_records(student_id);
CREATE INDEX IF NOT EXISTS idx_behavior_records_form_id ON behavior_records(form_id);
CREATE INDEX IF NOT EXISTS idx_behavior_goals_student_id ON behavior_goals(student_id);
CREATE INDEX IF NOT EXISTS idx_behavior_comments_student_id ON behavior_comments(student_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);