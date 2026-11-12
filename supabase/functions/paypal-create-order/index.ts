import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return Response.json(
        { error: "Method not allowed" },
        { status: 405, headers: corsHeaders },
      );
    }

    const clientId = Deno.env.get("PAYPAL_CLIENT_ID");
    const clientSecret = Deno.env.get("PAYPAL_CLIENT_SECRET");
    const baseUrl =
      Deno.env.get("PAYPAL_BASE_URL") ??
      "https://api-m.sandbox.paypal.com";

    if (!clientId || !clientSecret) {
      throw new Error("PayPal credentials belum dikonfigurasi.");
    }

    const body = await req.json();
    const amount = Number(body.amount);
    const currency = String(body.currency ?? "USD").toUpperCase();

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new Error("Nominal pembayaran tidak valid.");
    }

    if (currency !== "USD") {
      throw new Error("Saat ini hanya mendukung USD.");
    }

    // 1. Get PayPal access token
    const auth = btoa(`${clientId}:${clientSecret}`);

    const tokenResponse = await fetch(
      `${baseUrl}/v1/oauth2/token`,
      {
        method: "POST",
        headers: {
          Authorization: `Basic ${auth}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "grant_type=client_credentials",
      },
    );

    const tokenData = await tokenResponse.json();

    if (!tokenResponse.ok) {
      throw new Error(
        `PayPal authentication gagal: ${
          tokenData.error_description ?? JSON.stringify(tokenData)
        }`,
      );
    }

    // 2. Create PayPal order
    const orderResponse = await fetch(
      `${baseUrl}/v2/checkout/orders`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${tokenData.access_token}`,
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
              description: "NVIDIA App Savings Deposit",
            },
          ],
        }),
      },
    );

    const orderData = await orderResponse.json();

    if (!orderResponse.ok) {
      throw new Error(
        `PayPal create order gagal: ${JSON.stringify(orderData)}`,
      );
    }

    const approvalLink = orderData.links?.find(
      (link: { rel: string; href: string }) =>
        link.rel === "approve",
    );

    if (!approvalLink) {
      throw new Error("PayPal approval URL tidak ditemukan.");
    }

    return Response.json(
      {
        orderId: orderData.id,
        status: orderData.status,
        approvalUrl: approvalLink.href,
      },
      { headers: corsHeaders },
    );
  } catch (error) {
    console.error("PAYPAL CREATE ORDER ERROR:", error);

    return Response.json(
      {
        error: error instanceof Error
          ? error.message
          : String(error),
      },
      {
        status: 500,
        headers: corsHeaders,
      },
    );
  }
});
