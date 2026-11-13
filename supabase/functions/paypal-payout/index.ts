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
    const { userId, goalId, receiverEmail, amount, currency = "USD" } = await req.json()

    if (!userId || !receiverEmail || !amount) {
      return new Response(
        JSON.stringify({ error: "userId, receiverEmail, and amount are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const accessToken = await getPayPalAccessToken()
    const senderBatchId = `payout_${Date.now()}_${userId.slice(0, 5)}`

    // 1. Eksekusi Payouts API PayPal Sandbox
    const payoutResponse = await fetch("https://api-m.sandbox.paypal.com/v1/payments/payouts", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender_batch_header: {
          sender_batch_id: senderBatchId,
          email_subject: "Penarikan Tabungan Sukses!",
        },
        items: [
          {
            recipient_type: "EMAIL",
            amount: {
              value: amount.toFixed(2),
              currency: currency,
            },
            receiver: receiverEmail,
            note: "Penarikan dana tabungan dari aplikasi AI Savings",
            sender_item_id: `item_${Date.now()}`,
          },
        ],
      }),
    })

    const payoutData = await payoutResponse.json()

    if (!payoutResponse.ok) {
      throw new Error(`PayPal Payout Error: ${JSON.stringify(payoutData)}`)
    }

    const batchHeader = payoutData.batch_header
    const payoutBatchId = batchHeader.payout_batch_id

    // 2. Simpan Catatan ke Database Supabase
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Log Transaksi Penarikan
    await supabase.from("transactions").insert({
      user_id: userId,
      title: `Pencairan Tabungan ke ${receiverEmail}`,
      amount: amount,
      type: "expense",
      paypal_payout_id: payoutBatchId,
      payment_status: "completed",
    })

    // Log ke Savings Entries (Pengurangan Saldo Tabungan)
    if (goalId) {
      await supabase.from("savings_entries").insert({
        user_id: userId,
        goal_id: goalId,
        amount: -amount, // Minus karena dicairkan
        note: `Pencairan via PayPal (${payoutBatchId})`,
      })
    }

    return new Response(
      JSON.stringify({
        success: true,
        payoutBatchId: payoutBatchId,
        status: batchHeader.batch_status,
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