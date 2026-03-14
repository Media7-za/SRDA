import { createClient } from '@supabase/supabase-js';

// Fallback to dummy values for SSR/local if env vars aren't set
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'http://localhost:54321';
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'dummy_anon_key';

export const supabase = createClient(supabaseUrl, supabaseKey);
