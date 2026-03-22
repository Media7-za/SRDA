import { serve } from "std/http/server.ts"
import { createClient } from "supabase"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { refresh_token } = await req.json();

        if (!refresh_token) {
            throw { code: 'BAD_REQUEST', message: 'Missing refresh token', status: 400 };
        }

        const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
        const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';

        const supabase = createClient(supabaseUrl, supabaseAnonKey);

        const { data: refreshData, error: refreshError } = await supabase.auth.refreshSession({
            refresh_token
        });

        if (refreshError || !refreshData.session) {
            throw { code: 'UNAUTHORIZED', message: 'Session expired or invalid', status: 401 };
        }

        return new Response(
            JSON.stringify({
                success: true,
                data: {
                    token: refreshData.session.access_token,
                    refresh_token: refreshData.session.refresh_token,
                    expires_at: new Date(Date.now() + refreshData.session.expires_in * 1000).toISOString()
                }
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
        );

    } catch (err: any) {
        console.error(err);
        return new Response(
            JSON.stringify({
                success: false,
                data: null,
                error: {
                    code: err.code || 'INTERNAL_ERROR',
                    message: err.message || 'An unexpected error occurred'
                }
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: err.status || 500 }
        );
    }
})
