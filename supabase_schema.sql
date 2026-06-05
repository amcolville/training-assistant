-- JRNL Training Assistant — Supabase Schema
-- Ejecutar en Supabase > SQL Editor

-- Tabla principal de sesiones
create table if not exists sessions (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now(),
  date date default current_date,

  -- Actividad
  activity_type text,           -- trail, run, strength, climbing, rest...
  duration_min integer,         -- minutos
  distance_km numeric(6,2),
  elevation_m integer,
  hr_avg integer,
  hr_max integer,
  pace text,                    -- "7:30 /km"

  -- Input del atleta
  effort_rpe integer check (effort_rpe between 1 and 10),
  sleep_hours numeric(4,1),
  sleep_quality integer check (sleep_quality between 1 and 5),
  notes_raw text,               -- texto libre / transcripción del audio

  -- Procesado por Claude
  transcription text,           -- transcripción de Whisper
  physical_feelings text,       -- extraído por Claude
  mental_feelings text,         -- extraído por Claude
  claude_analysis text,         -- análisis completo de Claude
  next_session_rec text,        -- recomendación siguiente sesión
  recovery_rec text,            -- recomendación recuperación
  session_note text             -- nota final de Claude
);

-- Índice por fecha para consultas semanales
create index if not exists sessions_date_idx on sessions(date desc);

-- Vista: resumen semanal automático
create or replace view weekly_summary as
select
  date_trunc('week', date)::date as week_start,
  (date_trunc('week', date) + interval '6 days')::date as week_end,
  count(*) as total_sessions,
  sum(duration_min) as total_min,
  sum(distance_km) as total_km,
  sum(elevation_m) as total_elevation,
  round(avg(effort_rpe), 1) as avg_rpe,
  round(avg(sleep_hours), 1) as avg_sleep,
  round(avg(sleep_quality), 1) as avg_sleep_quality,
  array_agg(distinct activity_type) as disciplines
from sessions
where date is not null
group by date_trunc('week', date)
order by week_start desc;

-- RLS: desactivado para proyecto personal (un solo atleta)
alter table sessions disable row level security;
