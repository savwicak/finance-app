
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const apiKey = Deno.env.get("OPENAI_API_KEY");

    if (!apiKey) {
      return jsonResponse({
        error: "OPENAI_API_KEY belum diatur di Supabase Secrets.",
      }, 500);
    }

    const body = await req.json();
    const transactions = body.transactions;

    if (!Array.isArray(transactions)) {
      return jsonResponse({
        error: "Data transactions harus berupa array.",
      }, 400);
    }

    if (transactions.length === 0) {
      return jsonResponse({
        insight:
          "Belum ada transaksi yang tercatat. Yuk mulai catat pemasukan dan pengeluaranmu agar aku bisa membantu menganalisis kondisi keuanganmu.",
      });
    }

    // Batasi jumlah data agar request tetap ringan.
    const safeTransactions = transactions.slice(0, 100).map((t: any) => ({
      title: String(t.title ?? "Transaksi").slice(0, 100),
      category: String(t.category ?? "Lainnya").slice(0, 80),
      amount: Number(t.amount) || 0,
      type: String(t.type ?? "expense"),
      created_at: String(t.created_at ?? ""),
    }));

    const prompt = `
Kamu adalah AI Financial Assistant dalam aplikasi keuangan pribadi.

Analisis data transaksi pengguna berikut:
${JSON.stringify(safeTransactions)}

Tugasmu:
1. Identifikasi pola pengeluaran pengguna.
2. Temukan kategori dengan pengeluaran terbesar.
3. Berikan insight yang relevan berdasarkan data.
4. Berikan satu saran praktis untuk mengelola keuangan.
5. Jika datanya belum cukup, katakan dengan jujur.

Aturan:
- Gunakan bahasa Indonesia yang santai, jelas, dan mudah dipahami.
- Jangan mengarang angka atau transaksi.
- Jangan menganggap semua transaksi sebagai pengeluaran.
- Bedakan pemasukan dan pengeluaran berdasarkan field type.
- Jangan memberikan analisis yang tidak didukung data.
- Maksimal 3-4 kalimat.
- Jangan gunakan format JSON atau markdown.
`;

    const openAIResponse = await fetch(
      "https://api.openai.com/v1/responses",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: Deno.env.get("OPENAI_MODEL") || "gpt-6-astra",
          input: prompt,
        }),
      },
    );

    const result = await openAIResponse.json();

    if (!openAIResponse.ok) {
      console.error("OpenAI API error:", result);

      return jsonResponse({
        error:
          result?.error?.message ??
          "Gagal mendapatkan analisis dari OpenAI.",
      }, openAIResponse.status);
    }

    // Ambil teks dari output Responses API.
    const insight = (result.output ?? [])
      .filter((item: any) => item.type === "message")
      .flatMap((item: any) => item.content ?? [])
      .filter((item: any) => item.type === "output_text")
      .map((item: any) => item.text)
      .join("\n")
      .trim();

    if (!insight) {
      return jsonResponse({
        error: "OpenAI tidak mengembalikan hasil analisis.",
      }, 502);
    }

    return jsonResponse({ insight });
  } catch (error) {
    console.error("Financial insight error:", error);

    return jsonResponse({
      error: error instanceof Error
          ? error.message
          : "Terjadi kesalahan pada server.",
    }, 500);
  }
});
