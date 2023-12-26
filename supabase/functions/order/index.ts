// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { corsHeaders } from '../_shared/cors.ts'

const _supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {

    // This is needed if you're planning to invoke your function from a browser.
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders })
    }
   
    const orderData = await req.json();
    console.log(orderData);

    var price = 0;
    let occasionData = await _supabase
    .from("occasions")
    .select("price")
    .eq("id", orderData["occasion"])
    .single();
    price += occasionData["data"]!["price"];

    let optionsIds = Object.keys(orderData["options"]["options"]);

    let optionsData = await _supabase
    .from("options")
    .select("price")
    .in("id", optionsIds)

    for (let pr of optionsData.data!) {
      price += pr["price"];
    }

    let { data } = await _supabase
    .from("customers")
    .select("id")
    .eq("email", orderData["customer"]["email"])
    .maybeSingle();
    
    console.log(data);


    if(data===null)
    {
     ({ data } = await _supabase
      .from("customers")
      .insert(orderData["customer"])
      .select("id")
      .single());
    }

    console.log(data);

    var boxIds = Object.keys(orderData["options"]["box"]);
    let ticketResponse = await _supabase
      .from("tickets")
      .insert({
        "box":boxIds[0],
        "customer":data!["id"],
        "state":"reserved",
        "price":price,
        "occasion":orderData["occasion"],
    }).select("id").single();
    
    console.log(ticketResponse.data);

    await _supabase
    .from("boxes")
    .update({"type":"sold"})
    .eq("id", boxIds[0]);

    for(let opt of optionsIds) {
      console.log(ticketResponse.data!["id"]);
      await _supabase
      .from("ticket_option")
      .insert({"ticket":ticketResponse.data!["id"], "option":opt});
    }
    let toReturn = "{ id: "+ticketResponse.data!.id+"}";
    console.log(toReturn);
    JSON.stringify(ticketResponse.data)

    return new Response(JSON.stringify(ticketResponse.data), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/order' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

  curl -i --location --request POST 'https://zsyryiiwkcpjhtdptdhp.supabase.co/functions/v1/order' \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
  --header 'Content-Type: application/json' \
  --data '{"name":"Functions"}'

*/
