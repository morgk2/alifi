-- Create chargily_payments table
CREATE TABLE IF NOT EXISTS chargily_payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  payment_id TEXT UNIQUE NOT NULL,
  checkout_url TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Payment details
  client TEXT,
  client_email TEXT,
  invoice_number TEXT,
  amount DECIMAL(10,2),
  currency TEXT,
  payment_method TEXT,
  description TEXT,
  
  -- Webhook data
  webhook_data JSONB,
  payment_status TEXT,
  payment_amount DECIMAL(10,2),
  payment_currency TEXT,
  payment_date TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  metadata JSONB
);

-- Create store_orders table (if not exists)
CREATE TABLE IF NOT EXISTS store_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL,
  payment_id TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chargily_payments_payment_id ON chargily_payments(payment_id);
CREATE INDEX IF NOT EXISTS idx_chargily_payments_status ON chargily_payments(status);
CREATE INDEX IF NOT EXISTS idx_chargily_payments_created_at ON chargily_payments(created_at);

CREATE INDEX IF NOT EXISTS idx_store_orders_customer_id ON store_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_store_orders_payment_id ON store_orders(payment_id);
CREATE INDEX IF NOT EXISTS idx_store_orders_status ON store_orders(status);

-- Enable Row Level Security (RLS)
ALTER TABLE chargily_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_orders ENABLE ROW LEVEL SECURITY;

-- Create policies for chargily_payments
CREATE POLICY "Allow service role full access to chargily_payments" ON chargily_payments
  FOR ALL USING (auth.role() = 'service_role');

-- Allow users to read payment records (for payment status checking)
CREATE POLICY "Users can read payment records" ON chargily_payments
  FOR SELECT USING (true);

-- Create policies for store_orders
CREATE POLICY "Users can view their own orders" ON store_orders
  FOR SELECT USING (auth.uid()::text = customer_id);

CREATE POLICY "Allow service role full access to store_orders" ON store_orders
  FOR ALL USING (auth.role() = 'service_role');



