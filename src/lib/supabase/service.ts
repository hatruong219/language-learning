import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database'

const url = process.env.NEXT_PUBLIC_SUPABASE_URL
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!url) {
  throw new Error('NEXT_PUBLIC_SUPABASE_URL is not set')
}

if (!serviceRoleKey) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY is not set')
}

export function createServiceClient() {
  // Đã check ở trên, dùng non-null assertion để TS không báo lỗi trên Vercel
  return createClient<Database>(url!, serviceRoleKey!, {
    auth: { persistSession: false },
  })
}


