-- Fix RLS policies to allow inserting trading signals
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/nplgxhthjwwyywbnvxzt/sql/new

-- Allow anonymous inserts to trading_signals (for testing)
CREATE POLICY "Allow anonymous inserts for testing"
ON trading_signals
FOR INSERT
TO anon
WITH CHECK (true);

-- Allow anonymous reads
CREATE POLICY "Allow anonymous reads"
ON trading_signals
FOR SELECT
TO anon
USING (true);
