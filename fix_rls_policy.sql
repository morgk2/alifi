-- Fix RLS policy for chargily_payments table
-- This allows users to read payment records for status checking

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Users can read payment records" ON chargily_payments;

-- Create new policy that allows all users to read payment records
CREATE POLICY "Users can read payment records" ON chargily_payments
  FOR SELECT USING (true);

-- Verify the policy was created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'chargily_payments';

