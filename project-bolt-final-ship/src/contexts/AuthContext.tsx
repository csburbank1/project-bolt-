import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { User } from '@supabase/supabase-js';

interface Profile {
  id: string;
  full_name: string;
  role?: 'student' | 'staff';
  grade_level?: string;
  age_group?: 'kids' | 'teens' | 'adults';
  specialization?: string;
  profile_completed: boolean;
}

interface AuthContextType {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  error: string | null;
  signIn: (email: string, password: string) => Promise<{ user: User | null; error: Error | null }>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
  updatePassword: (newPassword: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Track if we're in the process of signing in
  const [isSigningIn, setIsSigningIn] = useState(false);

  async function fetchUserProfile(userId: string) {
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('Profile fetch error:', error);
      return null;
    }

    if (!profile.profile_completed) {
      console.log('Redirecting to onboarding - incomplete profile');
      return null;
    }

    return profile;
  }

  useEffect(() => {
    let mounted = true;

    async function getInitialSession() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (mounted) {
          setUser(session?.user ?? null);
          try {
            if (session?.user) {
              const profile = await fetchUserProfile(session.user.id);
              if (mounted && profile) {
                setProfile(profile);
              }
            }
          } catch (error) {
            console.error('Profile fetch error:', error);
          }
          setLoading(false);
        }
      } catch (error) {
        console.error('Error getting initial session:', error);
        if (mounted) {
          setLoading(false);
        }
      }
    }

    getInitialSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (mounted) {
        setUser(session?.user ?? null);
        if (session?.user) {
          try {
            const profile = await fetchUserProfile(session.user.id);
            if (mounted && profile) {
              setProfile(profile);
            }
          } catch (error) {
            console.error('Profile fetch error during auth change:', error);
            // Don't set error state here as it might be a normal onboarding flow
          }
        } else {
          setProfile(null);
        }
      }
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  async function signIn(email: string, password: string): Promise<{ user: User | null; error: Error | null }> {
    try {
      setError(null);
      setIsSigningIn(true);
      setLoading(true);
      
      // Input validation
      if (!email || !password) {
        throw new Error('Email and password are required');
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });
      
      if (error) {
        console.error('Auth error:', error);
        throw new Error(error.message);
      }

      if (!data?.user) {
        throw new Error('No user data received');
      }

      // Fetch profile data after successful sign in
      try {
        const profile = await fetchUserProfile(data.user.id);
        setProfile(profile);
      } catch (profileError) {
        console.error('Profile fetch error:', profileError);
        // Don't throw here - might need onboarding
      }

      return { user: data.user, error: null };
    } catch (err) {
      console.error('Sign in error:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred';
      setError(errorMessage);
      return { user: null, error: new Error(errorMessage) };
    } finally {
      setLoading(false);
      setIsSigningIn(false);
    }
  }

  async function signOut() {
    try {
      await supabase.auth.signOut();
      setUser(null);
      setProfile(null);
      setError(null);
    } catch (err) {
      console.error('Sign out error:', err);
      setError('Failed to sign out');
    }
  }

  // For initiating password reset flow
  async function resetPassword(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    if (error) throw error;
  }

  // For updating password after reset
  async function updatePassword(newPassword: string) {
    const { error } = await supabase.auth.updateUser({ 
      password: newPassword 
    });
    if (error) throw error;
  }

  const value = {
    user,
    profile,
    error,
    loading: loading || isSigningIn,
    signIn,
    signOut,
    resetPassword,
    updatePassword
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}