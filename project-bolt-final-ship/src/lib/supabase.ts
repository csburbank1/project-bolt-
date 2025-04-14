import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

// In production, we'll use environment variables from Netlify
if (import.meta.env.PROD && (!supabaseUrl || !supabaseAnonKey)) {
  console.warn('Supabase environment variables missing in production');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    debug: true
  },
  global: {
    headers: {
      'x-application-name': 'moodbuddy',
      'x-client-info': 'supabase-js@2.39.8'
    }
  }
});