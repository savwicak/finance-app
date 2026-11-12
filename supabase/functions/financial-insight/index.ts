import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  try {
    const { todayExpense, totalExpense, budgetTotal, budgetRemaining, categorySpending } =
      await req.json();

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) throw new Error("OPENAI_API_KEY belum dikonfigurasi.");

    const prompt = `
Kamu adalah AI financial assistant berbahasa Indonesia.
Buat insight singkat, ramah, dan spesifik (maksimal 2 kalimat).
Data:
- Pengeluaran hari ini: Rp${Number(todayExpense || 0)}
- Pengeluaran periode ini: Rp${Number(totalExpense || 0)}
- Total budget periode: Rp${Number(budgetTotal || 0)}
- Sisa budget: Rp${Number(budgetRemaining || 0)}
- Pengeluaran per kategori: ${JSON.stringify(categorySpending || [])}
Berikan saran praktis. Jangan mengarang data.
`;

    const aiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "Kamu adalah asisten keuangan pribadi." },
          { role: "user", content: prompt },
        ],
        temperature: 0.5,
        max_tokens: 120,
      }),
    });

    const result = await aiResponse.json();
    if (!aiResponse.ok) {
      throw new Error(result?.error?.message || "AI provider request failed.");
    }

    const insight = result?.choices?.[0]?.message?.content?.trim();
    return new Response(JSON.stringify({ insight }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
