create extension if not exists pgtap with schema extensions;

create schema if not exists tests;
revoke all on schema tests from public, anon, authenticated;

create or replace function tests.identity(p_name text)
returns uuid
language sql
immutable
strict
set search_path = ''
as $$
  select case p_name
    when 'admin' then '00000000-0000-0000-0000-000000000001'::uuid
    when 'user_press' then '00000000-0000-0000-0000-000000000002'::uuid
    when 'user_other_sector' then '00000000-0000-0000-0000-000000000003'::uuid
    when 'inactive_user' then '00000000-0000-0000-0000-000000000004'::uuid
    else null
  end
$$;

create or replace function tests.set_auth_context(
  p_user_id uuid,
  p_role text default 'authenticated'
)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform pg_catalog.set_config('request.jwt.claim.sub', coalesce(p_user_id::text, ''), false);
  perform pg_catalog.set_config('request.jwt.claim.role', p_role, false);
  perform pg_catalog.set_config(
    'request.jwt.claims',
    pg_catalog.json_build_object('sub', p_user_id, 'role', p_role)::text,
    false
  );
end;
$$;

create or replace function tests.clear_auth_context()
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform pg_catalog.set_config('request.jwt.claim.sub', '', false);
  perform pg_catalog.set_config('request.jwt.claim.role', '', false);
  perform pg_catalog.set_config('request.jwt.claims', '{}', false);
end;
$$;

set search_path = public, extensions;
begin;
select plan(4);
select has_schema('tests', 'test helper schema exists');
select has_function('tests', 'identity', array['text'], 'deterministic identities are available');
select has_function('tests', 'set_auth_context', array['uuid', 'text'], 'JWT claim helper is available');
select is(tests.identity('admin'), '00000000-0000-0000-0000-000000000001'::uuid, 'admin identity is stable');
select * from finish();
rollback;
