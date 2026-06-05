// api/sessions.js
// GET /api/sessions?range=week|day&date=YYYY-MM-DD
// Devuelve sesiones recientes o de una semana específica

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { range = 'week', date } = req.query;

    // Calcular rango de fechas
    const refDate = date ? new Date(date) : new Date();
    let from, to;

    if (range === 'day') {
      from = refDate.toISOString().split('T')[0];
      to = from;
    } else if (range === 'week') {
      // Semana lunes–domingo
      const day = refDate.getDay();
      const diffToMonday = (day === 0 ? -6 : 1 - day);
      const monday = new Date(refDate);
      monday.setDate(refDate.getDate() + diffToMonday);
      const sunday = new Date(monday);
      sunday.setDate(monday.getDate() + 6);
      from = monday.toISOString().split('T')[0];
      to = sunday.toISOString().split('T')[0];
    } else {
      // last N sessions
      const { data, error } = await supabase
        .from('sessions')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(20);
      if (error) throw error;
      return res.status(200).json({ sessions: data });
    }

    const { data: sessions, error } = await supabase
      .from('sessions')
      .select('*')
      .gte('date', from)
      .lte('date', to)
      .order('date', { ascending: false });

    if (error) throw error;

    // Calcular totales semanales
    const totals = sessions.reduce((acc, s) => ({
      sessions: acc.sessions + 1,
      duration_min: acc.duration_min + (s.duration_min || 0),
      distance_km: acc.distance_km + (s.distance_km || 0),
      elevation_m: acc.elevation_m + (s.elevation_m || 0),
    }), { sessions: 0, duration_min: 0, distance_km: 0, elevation_m: 0 });

    return res.status(200).json({
      range: { from, to },
      sessions,
      totals,
    });

  } catch (err) {
    console.error('Error en /api/sessions:', err);
    return res.status(500).json({ error: err.message });
  }
}
