-- ATLAS Training Mobile — backup privado por usuário (Supabase Free)
-- Execute no SQL Editor do SEU projeto Supabase.
-- NUNCA coloque chaves service_role no aplicativo ou no GitHub.

create table if not exists public.atlas_backups (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.atlas_backups enable row level security;
revoke all on public.atlas_backups from public, anon;
grant select, insert, update, delete on public.atlas_backups to authenticated;

drop policy if exists "atlas_select_own" on public.atlas_backups;
drop policy if exists "atlas_insert_own" on public.atlas_backups;
drop policy if exists "atlas_update_own" on public.atlas_backups;
drop policy if exists "atlas_delete_own" on public.atlas_backups;

create policy "atlas_select_own" on public.atlas_backups
  for select to authenticated using (user_id = (select auth.uid()));
create policy "atlas_insert_own" on public.atlas_backups
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "atlas_update_own" on public.atlas_backups
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy "atlas_delete_own" on public.atlas_backups
  for delete to authenticated using (user_id = (select auth.uid()));

create or replace function public.atlas_mark_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists atlas_touch_updated_at on public.atlas_backups;
create trigger atlas_touch_updated_at before update on public.atlas_backups
for each row execute function public.atlas_mark_updated_at();

-- Importante: ao usar o editor de modelos de e-mail do Supabase,
-- personalize o template "Magic Link" para exibir o código {{ .Token }}.
-- O ATLAS solicita o código para acesso sem senha à nuvem.
