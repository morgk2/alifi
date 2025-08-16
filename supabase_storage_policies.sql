-- Create policies for the pet-photos bucket
BEGIN;

-- Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy for uploads (INSERT)
CREATE POLICY "Allow authenticated uploads" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'pet-photos' AND auth.role() = 'authenticated');

-- Policy for viewing photos (SELECT)
CREATE POLICY "Allow public viewing of pet photos" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id = 'pet-photos');

-- Policy for deleting own photos (DELETE)
CREATE POLICY "Allow users to delete own photos" 
ON storage.objects FOR DELETE 
TO authenticated 
USING (
  bucket_id = 'pet-photos' AND 
  auth.role() = 'authenticated'
);

COMMIT; 