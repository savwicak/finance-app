export async function getPayPalAccessToken(): Promise<string> {
  const clientId = Deno.env.get("PAYPAL_CLIENT_ID")!
  const clientSecret = Deno.env.get("PAYPAL_SECRET")!
  const authUrl = "https://api-m.sandbox.paypal.com/v1/oauth2/token"

  const credentials = btoa(`${clientId}:${clientSecret}`)

  const response = await fetch(authUrl, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${credentials}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  })

  const data = await response.json()
  if (!response.ok) {
    throw new Error(`Failed to get PayPal Token: ${JSON.stringify(data)}`)
  }
  return data.access_token
}