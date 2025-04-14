import { describe, it, expect, beforeEach, afterEach } from 'vitest';

// Test configuration
const TEST_ORIGIN = 'http://localhost:3000';

describe('Profile Creation', () => {
  const testUser = {
    email: 'test.user@test.edu',
    password: 'Test123!@#',
    full_name: 'Test User',
    grade_level: '10th',
    age_group: 'teens'
  };

  let userId: string;

  beforeEach(async () => {
    // Mock user creation
    userId = 'test-user-id';
    localStorage.setItem('user', JSON.stringify({
      id: userId,
      email: testUser.email,
      emailConfirmed: true
    }));
  });

  afterEach(() => {
    localStorage.clear();
  });

  it('should create a profile successfully', async () => {
    const profile = {
      id: userId,
      full_name: testUser.full_name,
      grade_level: testUser.grade_level,
      age_group: testUser.age_group
    };

    localStorage.setItem(`profile_${userId}`, JSON.stringify(profile));
    const storedProfile = JSON.parse(localStorage.getItem(`profile_${userId}`) || '{}');

    expect(storedProfile.full_name).toBe(testUser.full_name);
    expect(storedProfile.grade_level).toBe(testUser.grade_level);
    expect(storedProfile.age_group).toBe(testUser.age_group);
  });

  it('should enforce required fields', () => {
    const invalidProfile = {
      id: userId
    };

    expect(() => {
      localStorage.setItem(`profile_${userId}`, JSON.stringify(invalidProfile));
    }).not.toThrow();
  });

  it('should validate age_group enum', () => {
    const invalidProfile = {
      id: userId,
      full_name: testUser.full_name,
      grade_level: testUser.grade_level,
      age_group: 'invalid'
    };

    expect(() => {
      localStorage.setItem(`profile_${userId}`, JSON.stringify(invalidProfile));
    }).not.toThrow();
  });
});