// api/weekly.js
// POST /api/weekly
// Genera resumen semanal con Claude a partir de las sesiones de la semana

import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { date } = JSON.parse(req.body || '{}');

    const refDate = date ? new Date(date) : new Date();
    const day = refDate.getDay();
    const diffToMonday = (day === 0 ? -6 : 1 - day);
    const monday = new Date(refDate);
    monday.setDate(refDate.getDate() + diffToMonday);
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);
    const from = monday.toISOString().split('T')[0];
    const to = sunday.toISOString().split('T')[0];

    // Obtener sesiones de la semana
    const { data: sessions, error } = await supabase
      .from('sessions')
      .select('*')
      .gte('date', from)
      .lte('date', to)
      .order('date', { ascending: true });

    if (error) throw error;
    if (!sessions || sessions.length === 0) {
      return res.status(200).json({ error: 'No hay sesiones esta semana' });
    }

    // Construir resumen de sesiones para Claude
    const sessionsSummary = sessions.map((s, i) => `
Sesión ${i + 1} (${s.date}):
- Actividad: ${s.activity_type || 'no especificada'}
- Duración: ${s.duration_min ? s.duration_min + ' min' : '—'}
- Distancia: ${s.distance_km ? s.distance_km + ' km' : '—'}
- D+: ${s.elevation_m ? s.elevation_m + ' m' : '—'}
- RPE: ${s.effort_rpe || '—'}/10
- FC media: ${s.hr_avg || '—'} bpm
- Sueño: ${s.sleep_hours || '—'} h, calidad ${s.sleep_quality || '—'}/5
- Sensaciones físicas: ${s.physical_feelings || s.notes_raw || '—'}
- Sensaciones mentales: ${s.mental_feelings || '—'}
- Análisis: ${s.claude_analysis || '—'}
`).join('\n---\n');

    const totals = sessions.reduce((acc, s) => ({
      sessions: acc.sessions + 1,
      duration_min: acc.duration_min + (s.duration_min || 0),
      distance_km: acc.distance_km + (parseFloat(s.distance_km) || 0),
      elevation_m: acc.elevation_m + (s.elevation_m || 0),
    }), { sessions: 0, duration_min: 0, distance_km: 0, elevation_m: 0 });

    const prompt = `Analiza esta semana de entrenamiento del atleta y genera un resumen semanal.

SEMANA: ${from} al ${to}
TOTALES: ${totals.sessions} sesiones, ${totals.duration_min} min, ${totals.distance_km.toFixed(1)} km, ${totals.elevation_m} m D+

SESIONES:
${sessionsSummary}

Responde SOLO con JSON, sin markdown:
{
  "week_start_feelings": "cómo llegó el atleta a la semana (infiere del contexto)",
  "week_mid_feelings": "energía y sensaciones durante la semana",
  "week_end_feelings": "cómo se cerró la semana",
  "highlights": ["hito 1", "hito 2"],
  "insights": "análisis cruzado de datos y sensaciones — lo que los números solos no cuentan",
  "next_week_prioritize": "qué priorizar la semana siguiente",
  "next_week_moderate": "qué moderar",
  "next_week_watch": "qué vigilar"
}`;

    const claudeResponse = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      messages: [{ role: 'user', content: prompt }],
    });

    const rawText = claudeResponse.content[0].text.trim();
    let summary;
    try {
      summary = JSON.parse(rawText);
    } catch {
      const match = rawText.match(/\{[\s\S]*\}/);
      summary = match ? JSON.parse(match[0]) : { insights: rawText };
    }

    return res.status(200).json({
      range: { from, to },
      totals,
      sessions,
      summary,
    });

  } catch (err) {
    console.error('Error en /api/weekly:', err);
    return res.status(500).json({ error: err.message });
  }
}
