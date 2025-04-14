/*
  # Optimize Database Policies

  1. Changes
    - Replace nested SELECT queries in policies with simpler conditions
    - Add composite indexes for better query performance
    - Update RLS policies to be more efficient

  2. Security
    - Maintain same security rules but with optimized implementation
    - All policies still enforce proper access control
*/

-- Drop existing policies that use inefficient nested selects
DROP POLICY IF EXISTS "Staff can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Staff can manage behavior forms" ON behavior_forms;
DROP POLICY IF EXISTS "Students can view active behavior forms" ON behavior_forms;
DROP POLICY IF EXISTS "Staff can manage all behavior records" ON behavior_records;
DROP POLICY IF EXISTS "Staff can manage behavior goals" ON behavior_goals;
DROP POLICY IF EXISTS "Staff can manage behavior comments" ON behavior_comments;

-- Create composite index for user roles to optimize role checks
CREATE INDEX IF NOT EXISTS idx_user_roles_user_role ON user_roles(user_id, role);

-- Recreate policies with optimized conditions
CREATE POLICY "Staff can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'staff'
  );

CREATE POLICY "Staff can manage behavior forms"
  ON behavior_forms FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'staff'
  );

CREATE POLICY "Students can view active behavior forms"
  ON behavior_forms FOR SELECT
  TO authenticated
  USING (
    is_active = true AND
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'student'
  );

CREATE POLICY "Staff can manage all behavior records"
  ON behavior_records FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'staff'
  );

CREATE POLICY "Staff can manage behavior goals"
  ON behavior_goals FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'staff'
  );

CREATE POLICY "Staff can manage behavior comments"
  ON behavior_comments FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'staff'
  );

-- Add composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_behavior_records_student_date ON behavior_records(student_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_behavior_goals_student_status ON behavior_goals(student_id, status);
CREATE INDEX IF NOT EXISTS idx_behavior_comments_student_created ON behavior_comments(student_id, created_at DESC);