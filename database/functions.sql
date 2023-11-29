-- Example: enable the "http" extension
create extension http with schema extensions;

--drop function send_email_mailersend;
CREATE OR REPLACE FUNCTION send_email_mailersend (message JSONB, subs JSONB)
  RETURNS json
  LANGUAGE plpgsql
  SECURITY DEFINER -- required in order to read keys in the private schema
  -- Set a secure search_path: trusted schema(s), then 'pg_temp'.
  -- SET search_path = admin, pg_temp;
  AS $$
DECLARE
  retval json;
  MAILERSEND_API_TOKEN text;
BEGIN
  SELECT value::text INTO MAILERSEND_API_TOKEN FROM private_keys WHERE key = 'MAILERSEND_API_TOKEN';
  IF NOT found THEN RAISE 'missing entry in private_keys: MAILERSEND_API_TOKEN'; END IF;

    SELECT
        * INTO retval
    FROM
        http
        ((
            'POST',
            'https://api.mailersend.com/v1/email',
            ARRAY[http_header ('Authorization',
            'Bearer ' || MAILERSEND_API_TOKEN
            ), http_header ('X-Requested-With', 'XMLHttpRequest')],
            'application/json',
            json_build_object(
                  'to', json_build_array(
                    json_build_object(
                      'email', message->>'recipient'
                    )
                  ),
                  'template_id', message->>'template_id',
                  'reply_to', json_build_array(
                    json_build_object(
                      'email', message->>'recipient',
                      'name', 'AV23'
                    )
                  ),
                  'variables', json_build_array(
                    json_build_object(
                      'email', message->>'recipient',
                      'substitutions', subs
                    )
                  )
            )::text

        ));

        IF retval::text = '202' THEN
          RAISE NOTICE 'message sent with mailersend: %',retval;
        ELSE
          RAISE 'error sending message with mailersend: %',retval;
        END IF;

  RETURN retval;
END;
$$;