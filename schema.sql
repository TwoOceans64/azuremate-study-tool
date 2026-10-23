create table public.questions (
  id int primary key,
  domain text not null check (domain in ('c','a','m')),
  question text not null,
  options jsonb not null,
  explanation text not null,
  simple text not null
);
create table public.attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  question_id int not null references public.questions on delete cascade,
  correct boolean not null,
  mode text not null default 'practice' check (mode in ('practice','mock')),
  created_at timestamptz not null default now()
);
create table public.mock_results (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  score int not null check (score between 0 and 1000),
  correct int not null,
  total int not null,
  created_at timestamptz not null default now()
);
create table public.study_settings (
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  exam_date date,
  hours_per_week int not null default 5
);
alter table public.questions enable row level security;
alter table public.attempts enable row level security;
alter table public.mock_results enable row level security;
alter table public.study_settings enable row level security;
create policy "anyone reads questions" on public.questions for select to anon, authenticated using (true);
create policy "own attempts" on public.attempts for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own mock results" on public.mock_results for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own settings" on public.study_settings for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
