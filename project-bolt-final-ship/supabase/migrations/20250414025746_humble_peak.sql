/*
  # Seed Initial Achievements

  This migration adds the initial set of achievements that users can earn
  in the MoodBuddy application.
*/

INSERT INTO achievements (name, description, criteria, points, badge_url)
VALUES
  (
    'Early Bird',
    'Complete 5 morning check-ins',
    '{"type": "check_ins", "count": 5, "time_range": "morning"}',
    50,
    'https://api.dicebear.com/7.x/shapes/svg?seed=earlybird'
  ),
  (
    'Streak Master',
    'Maintain a 7-day streak',
    '{"type": "streak", "days": 7}',
    100,
    'https://api.dicebear.com/7.x/shapes/svg?seed=streakmaster'
  ),
  (
    'Reflection Guru',
    'Complete 10 daily reflections',
    '{"type": "reflections", "count": 10}',
    150,
    'https://api.dicebear.com/7.x/shapes/svg?seed=guru'
  )
ON CONFLICT (id) DO NOTHING;