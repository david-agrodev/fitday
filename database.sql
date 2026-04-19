-- ══════════════════════════════════════════════════════════════════════════
-- FITDAY — BANCO DE DADOS SUPABASE
-- Execute este SQL no SQL Editor do seu projeto Supabase
-- ══════════════════════════════════════════════════════════════════════════

-- ── 1. PROFILES (criado automaticamente no signup) ───────────────────────
create table public.profiles (
  id          uuid references auth.users on delete cascade primary key,
  name        text not null,
  email       text,
  avatar_url  text,
  created_at  timestamptz default now()
);

-- ── 2. CAMINHADAS ────────────────────────────────────────────────────────
create table public.walks (
  id               uuid default gen_random_uuid() primary key,
  user_id          uuid references public.profiles(id) on delete cascade not null,
  distance_km      numeric(6,2) not null,
  steps            integer,
  duration_minutes integer,
  calories         integer,
  date             date not null,
  notes            text,
  created_at       timestamptz default now()
);

-- ── 3. HÁBITOS (definição) ───────────────────────────────────────────────
create table public.habits (
  id          uuid default gen_random_uuid() primary key,
  user_id     uuid references public.profiles(id) on delete cascade not null,
  name        text not null,
  icon_name   text default 'check-sq',
  color_bg    text default '#F1F5F9',
  color_ic    text default '#1E293B',
  frequency   text default 'daily' check (frequency in ('daily','weekdays','weekends')),
  active      boolean default true,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);

-- ── 4. HABIT LOGS (registro diário) ─────────────────────────────────────
create table public.habit_logs (
  id          uuid default gen_random_uuid() primary key,
  habit_id    uuid references public.habits(id) on delete cascade not null,
  user_id     uuid references public.profiles(id) on delete cascade not null,
  date        date not null,
  completed   boolean default false,
  created_at  timestamptz default now(),
  unique(habit_id, date)
);

-- ── 5. METAS ─────────────────────────────────────────────────────────────
create table public.goals (
  id            uuid default gen_random_uuid() primary key,
  user_id       uuid references public.profiles(id) on delete cascade not null,
  type          text not null check (type in ('steps','distance','habits','streak','calories')),
  target_value  numeric not null,
  unit          text,
  period        text default 'weekly' check (period in ('daily','weekly','monthly')),
  active        boolean default true,
  created_at    timestamptz default now()
);

-- ══════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) — cada usuário só acessa seus próprios dados
-- ══════════════════════════════════════════════════════════════════════════

alter table public.profiles    enable row level security;
alter table public.walks       enable row level security;
alter table public.habits      enable row level security;
alter table public.habit_logs  enable row level security;
alter table public.goals       enable row level security;

-- Profiles
create policy "profiles_select" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);

-- Walks
create policy "walks_all" on public.walks for all using (auth.uid() = user_id);

-- Habits
create policy "habits_all" on public.habits for all using (auth.uid() = user_id);

-- Habit logs
create policy "habit_logs_all" on public.habit_logs for all using (auth.uid() = user_id);

-- Goals
create policy "goals_all" on public.goals for all using (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════════════════════════
-- TRIGGER: cria profile automaticamente após signup
-- ══════════════════════════════════════════════════════════════════════════

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ══════════════════════════════════════════════════════════════════════════
-- DADOS DE EXEMPLO (opcional — apague se não quiser)
-- ══════════════════════════════════════════════════════════════════════════

-- Insira depois de criar seu primeiro usuário via Auth
-- Substitua 'SEU-USER-UUID' pelo UUID real do seu usuário

/*
insert into public.habits (user_id, name, icon_name, color_bg, color_ic, sort_order) values
  ('SEU-USER-UUID', 'Caminhar 30 min',          'run',       '#FFF7ED', '#F97316', 1),
  ('SEU-USER-UUID', 'Beber 3L de água',          'drop',      '#EFF6FF', '#3B82F6', 2),
  ('SEU-USER-UUID', 'Comer frutas',              'salad',     '#F0FDF4', '#22C55E', 3),
  ('SEU-USER-UUID', 'Dormir 8 horas',            'moon',      '#FEF3C7', '#D97706', 4),
  ('SEU-USER-UUID', 'Sem tela antes de dormir',  'phone-off', '#F8FAFC', '#94A3B8', 5),
  ('SEU-USER-UUID', 'Meditação 10 min',          'brain',     '#F5F3FF', '#7C3AED', 6);

insert into public.goals (user_id, type, target_value, unit, period) values
  ('SEU-USER-UUID', 'steps',    10000,  'passos', 'daily'),
  ('SEU-USER-UUID', 'distance', 30,     'km',     'weekly'),
  ('SEU-USER-UUID', 'habits',   30,     'hab',    'weekly'),
  ('SEU-USER-UUID', 'distance', 100,    'km',     'monthly');
*/
