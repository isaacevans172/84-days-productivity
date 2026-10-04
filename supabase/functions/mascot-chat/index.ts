import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const DEEPSEEK_API_URL =
    "https://api.deepseek.com/chat/completions"

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
}

interface MascotRequest {
    message: string
    mascotName?: string
    expression?: string
    context?: string
}

Deno.serve(async (req: Request) => {

    // Handle preflight requests
    if (req.method === "OPTIONS") {
        return new Response("ok", {
            headers: corsHeaders,
        })
    }

    // Only allow POST
    if (req.method !== "POST") {
        return new Response(
            JSON.stringify({
                error: "Method not allowed",
            }),
            {
                status: 405,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/json",
                },
            }
        )
    }

    try {

        const apiKey =
            Deno.env.get("DEEPSEEK_API_KEY")

        if (!apiKey) {
            console.error(
                "DEEPSEEK_API_KEY is not configured"
            )

            return new Response(
                JSON.stringify({
                    error: "AI service is not configured.",
                }),
                {
                    status: 500,
                    headers: {
                        ...corsHeaders,
                        "Content-Type":
                            "application/json",
                    },
                }
            )
        }

        const body =
            (await req.json()) as MascotRequest

        const message =
            body.message?.trim()

        if (!message) {
            return new Response(
                JSON.stringify({
                    error: "Message is required.",
                }),
                {
                    status: 400,
                    headers: {
                        ...corsHeaders,
                        "Content-Type":
                            "application/json",
                    },
                }
            )
        }

        const mascotName =
            body.mascotName || "84Days Mascot"

        const expression =
            body.expression || "happy"

        const context =
            body.context || ""

        const systemPrompt = `
You are the mascot companion inside an app called 84Days.

Your personality is:
- witty
- slightly sarcastic
- warm underneath the sarcasm
- encouraging without being cheesy
- confident
- occasionally chaotic
- never mean or insulting
- conversational and natural

You are helping the user build better habits over an 84-day journey.

Your responses should feel like they are coming from an actual character, not an AI assistant.

Keep responses SHORT.
Usually 1-3 sentences.
Do not give long explanations unless the user specifically asks for one.

Do not constantly mention 84Days.
Do not constantly say "you've got this".
Avoid generic motivational clichés.

Mascot name:
${mascotName}

Current expression:
${expression}

Additional context:
${context}
`

        const deepSeekResponse =
            await fetch(DEEPSEEK_API_URL, {
                method: "POST",

                headers: {
                    "Content-Type":
                        "application/json",
                    "Authorization":
                        `Bearer ${apiKey}`,
                },

                body: JSON.stringify({
                    model: "deepseek-flash",

                    messages: [
                        {
                            role: "system",
                            content: systemPrompt,
                        },
                        {
                            role: "user",
                            content: message,
                        },
                    ],

                    thinking: {
                        type: "disabled",
                    },

                    max_tokens: 150,

                    stream: false,
                }),
            })

        if (!deepSeekResponse.ok) {

            const errorText =
                await deepSeekResponse.text()

            console.error(
                "DeepSeek error:",
                errorText
            )

            return new Response(
                JSON.stringify({
                    error:
                        "The mascot couldn't respond right now.",
                }),
                {
                    status: 502,
                    headers: {
                        ...corsHeaders,
                        "Content-Type":
                            "application/json",
                    },
                }
            )
        }

        const data =
            await deepSeekResponse.json()

        const reply =
            data?.choices?.[0]?.message?.content

        if (!reply) {

            console.error(
                "DeepSeek returned no message:",
                data
            )

            return new Response(
                JSON.stringify({
                    error:
                        "The mascot returned an empty response.",
                }),
                {
                    status: 502,
                    headers: {
                        ...corsHeaders,
                        "Content-Type":
                            "application/json",
                    },
                }
            )
        }

        return new Response(
            JSON.stringify({
                reply: reply.trim(),
            }),
            {
                status: 200,
                headers: {
                    ...corsHeaders,
                    "Content-Type":
                        "application/json",
                },
            }
        )

    } catch (error) {

        console.error(
            "Mascot function error:",
            error
        )

        return new Response(
            JSON.stringify({
                error:
                    "Something went wrong talking to the mascot.",
            }),
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type":
                        "application/json",
                },
            }
        )
    }
})
