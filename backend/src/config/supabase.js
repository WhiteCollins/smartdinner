const { createClient } = require('@supabase/supabase-js');

// Configuración de Supabase
const supabaseUrl = process.env.SUPABASE_URL || 'https://tu-proyecto.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY || 'tu-service-role-key-aqui';

// Crear cliente de Supabase con service_role key (para operaciones de backend)
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false
  }
});

// Cliente de Supabase con anon key (para operaciones de usuarios)
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || 'tu-anon-key-aqui';
const supabaseClient = createClient(supabaseUrl, supabaseAnonKey);

module.exports = {
  supabase,
  supabaseClient,
  supabaseUrl
};
