import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { getPayPalAccessToken } from "../_shared/paypal.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { userId, goalId, amount, currency = "USD" } = await req.json()

    if (!userId || !amount) {
      return new Response(JSON.stringify({ error: "userId and amount are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const accessToken = await getPayPalAccessToken()

    // 1. Buat Order di PayPal Sandbox
    const orderResponse = await fetch("https://api-m.sandbox.paypal.com/v2/checkout/orders", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        intent: "CAPTURE",
        purchase_units: [
          {
            amount: {
              currency_code: currency,
              value: amount.toFixed(2),
            },
            description: `Deposit Savings Goal ID: ${goalId || 'General Savings'}`,
          },
        ],
      }),
    })

    const orderData = await orderResponse.json()

    if (!orderResponse.ok) {
      throw new Error(`PayPal Order Error: ${JSON.stringify(orderData)}`)
    }

    // 2. Inisialisasi Supabase Client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. Simpan log transaksi awal dengan status 'pending'
    await supabase.from("transactions").insert({
      user_id: userId,
      title: "Deposit Tabungan via PayPal",
      amount: amount,
      type: "income",
      paypal_order_id: orderData.id,
      payment_status: "pending",
    })

    return new Response(
      JSON.stringify({
        success: true,
        orderId: orderData.id,
        approvalUrl: orderData.links.find((l: any) => l.rel === "approve")?.href,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})