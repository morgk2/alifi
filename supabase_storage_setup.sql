-- Create chat-media storage bucket using Supabase Dashboard
-- Go to Storage > Create Bucket
-- Name: chat-media
-- Public: Yes (checked)
-- 
-- Then set up these RLS policies in the Supabase Dashboard:
-- Go to Storage > chat-media > Policies

-- Policy 1: "Allow authenticated users to upload"
-- Operation: INSERT
-- Target roles: authenticated
-- USING expression: true
-- WITH CHECK expression: true

-- Policy 2: "Allow public read access"
-- Operation: SELECT  
-- Target roles: public
-- USING expression: true

-- Policy 3: "Allow users to update their own files"
-- Operation: UPDATE
-- Target roles: authenticated
-- USING expression: auth.uid()::text = (storage.foldername(name))[1]

-- Policy 4: "Allow users to delete their own files"
-- Operation: DELETE
-- Target roles: authenticated
-- USING expression: auth.uid()::text = (storage.foldername(name))[1]

-- Alternative: Create bucket via SQL (if you have admin access)
-- INSERT INTO storage.buckets (id, name, public) 
-- VALUES ('chat-media', 'chat-media', true)
-- ON CONFLICT (id) DO NOTHING;
