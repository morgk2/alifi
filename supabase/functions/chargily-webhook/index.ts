// @deno-types="https://deno.land/x/deno@v1.40.0/lib.deno.d.ts"
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Test endpoint
  if (req.url.includes('test')) {
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Webhook is working!',
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  }

  try {
    // Get the request body with better error handling
    let body
    try {
      body = await req.json()
      console.log('Chargily webhook received:', JSON.stringify(body, null, 2))
    } catch (jsonError) {
      console.error('Error parsing JSON:', jsonError)
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Invalid JSON body' 
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    // Verify the webhook signature (you should implement this)
    // const signature = req.headers.get('x-chargily-signature')
    // if (!verifySignature(body, signature, process.env.CHARGILY_WEBHOOK_SECRET)) {
    //   throw new Error('Invalid webhook signature')
    // }

    // Extract payment data from Chargily webhook structure
    const {
      id: eventId,
      type: eventType,
      data: paymentData
    } = body

    console.log('Event ID:', eventId)
    console.log('Event Type:', eventType)
    console.log('Payment Data:', JSON.stringify(paymentData, null, 2))

    // Extract data from the nested structure
    const {
      id: paymentId,
      status,
      amount,
      currency,
      metadata,
      created_at,
      updated_at
    } = paymentData || body // Fallback to root level if data doesn't exist

    console.log('Extracted payment ID:', paymentId)
    console.log('Extracted status:', status)
    console.log('Extracted amount:', amount)
    console.log('Extracted currency:', currency)
    console.log('Extracted metadata:', JSON.stringify(metadata, null, 2))

    // Validate required fields
    if (!paymentId || !status) {
      console.error('Missing required fields:', { paymentId, status })
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Missing required fields: paymentId or status' 
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400 
        }
      )
    }

    console.log(`Processing payment ${paymentId} with status: ${status}`)

    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase environment variables')
    }
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // Update payment status in your database
    console.log(`Attempting to update payment ${paymentId} with status: ${status}`)
    
         try {
       // Always try to insert first (upsert behavior)
       console.log('Inserting/updating payment record...')
       const { data: upsertData, error: upsertError } = await supabase
         .from('chargily_payments')
         .upsert({
           payment_id: paymentId,
           status: status,
           webhook_data: body,
           payment_status: status,
           payment_amount: amount,
           payment_currency: currency,
           payment_date: new Date(updated_at * 1000).toISOString(), // Convert timestamp to ISO
           created_at: new Date().toISOString(),
           updated_at: new Date().toISOString(),
         }, {
           onConflict: 'payment_id'
         })
         .select()
       
       if (upsertError) {
         console.error('Error upserting payment:', upsertError)
         console.error('Upsert error details:', JSON.stringify(upsertError, null, 2))
       } else {
         console.log(`Payment ${paymentId} record upserted with status: ${status}`)
         console.log('Upserted data:', JSON.stringify(upsertData, null, 2))
       }
     } catch (dbError) {
       console.error('Database operation failed:', dbError)
       console.error('Database error details:', JSON.stringify(dbError, null, 2))
     }

    // If payment is successful, create order
    if (status === 'paid' && metadata) {
      const {
        userId,
        productId,
        productName,
        quantity,
        orderType,
        productCurrency,
        paymentAmount,
        appFee,
        totalAmount
      } = metadata

      if (orderType === 'product_purchase') {
        try {
          // Create order in your orders table
          // Use the original product amount (without app fee) for the order
          const orderAmount = parseFloat(paymentAmount) || (amount - (appFee || 0))
          
          const { error: orderError } = await supabase
            .from('store_orders')
            .insert({
              customer_id: userId,
              product_id: productId,
              product_name: productName,
              quantity: parseInt(quantity) || 1,
              total_amount: orderAmount, // Product amount without app fee
              currency: productCurrency || currency,
              payment_id: paymentId,
              status: 'paid',
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            })

          if (orderError) {
            console.error('Error creating order:', orderError)
            // Don't throw here, payment was successful
          } else {
            console.log(`Order created for payment ${paymentId} with amount: ${orderAmount} (total paid: ${totalAmount || amount})`)
          }
        } catch (orderError) {
          console.error('Exception creating order:', orderError)
        }
      }
    }

    // Send notification to user (optional)
    if (status === 'paid' && metadata?.userId) {
      console.log(`Payment successful for user: ${metadata.userId}`)
      // TODO: Implement push notification here
      // You can call your Firebase function to send notifications
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Webhook processed successfully',
        payment_id: paymentId,
        status: status
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Webhook error:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})

// Function to verify webhook signature (implement this)
function verifySignature(payload: any, signature: string, secret: string): boolean {
  // Implement HMAC verification here
  // For now, return true (you should implement proper verification)
  return true
}
