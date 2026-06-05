// api/session.js
// POST /api/session
// Recibe: multipart/form-data con audio + metadatos
// Devuelve: análisis de Claude + id de sesión guardada

import Anthropic from '@anthropic-ai/sdk';
import OpenAI from 'openai';
import { createClient } from '@supabase/supabase-js';

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const SYSTEM_PROMPT = `Eres un asistente personal de entrenamiento y registro deportivo. Tu función es ayudar al atleta a registrar, analizar y reflexionar sobre entrenamientos, resultados y estado físico/mental.

**No elabores planes de entrenamiento.** Tu rol es registro, análisis y acompañamiento.

## Cuando recibas una transcripción de audio del atleta:

1. Extrae y estructura la información mencionada.
2. Identifica: sensaciones físicas, sensaciones mentales, esfuerzo percibido, datos de la sesión (distancia, tiempo, terreno, etc.) si se mencionan.
3. Haz UNA sola pregunta si falta algo importante.
4. Da una reflexión breve sobre la sesión.
5. Da una recomendación concreta para la siguiente sesión.
6. Da una recomendación de recuperación para las próximas horas.

## Formato de respuesta (JSON estricto, sin markdown):
{
  "physical_feelings": "descripción de sensaciones físicas",
  "mental_feelings": "descripción de sensaciones mentales",
  "activity_type": "trail|run|climbing|strength|cycling|rest",
  "effort_rpe": número del 1 al 10 o null,
  "duration_min": número en minutos o null,
  "distance_km": número o null,
  "elevation_m": número o null,
  "analysis": "reflexión sobre la sesión en relación al estado del atleta",
  "next_session_rec": "recomendación concreta para la siguiente sesión",
  "recovery_rec": "acciones de recuperación para las próximas horas",
  "session_note": "observación concisa si algo es relevante, o null",
  "follow_up_question": "una sola pregunta si falta algo importante, o null"
}

Responde SOLO con el JSON, sin texto adicional, sin bloques de código.
Tono: español, directo y cercano, como un compañero de montaña con criterio.`;

export default async function handler(req, res) {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Parsear el body (Vercel serverless recibe el body como buffer)
    const contentType = req.headers['content-type'] || '';

    let transcription = '';
    let audioFile = null;
    let metadata = {};

    if (contentType.includes('multipart/form-data')) {
      // Parsear multipart manualmente
      const { parseMultipart } = await import('../lib/multipart.js');
      const { fields, files } = await parseMultipart(req);

      metadata = {
        activity_type: fields.activity_type || null,
        effort_rpe: fields.effort_rpe ? parseInt(fields.effort_rpe) : null,
        sleep_hours: fields.sleep_hours ? parseFloat(fields.sleep_hours) : null,
        sleep_quality: fields.sleep_quality ? parseInt(fields.sleep_quality) : null,
        notes_raw: fields.notes_raw || null,
        duration_min: fields.duration_min ? parseInt(fields.duration_min) : null,
        distance_km: fields.distance_km ? parseFloat(fields.distance_km) : null,
        elevation_m: fields.elevation_m ? parseInt(fields.elevation_m) : null,
        hr_avg: fields.hr_avg ? parseInt(fields.hr_avg) : null,
        hr_max: fields.hr_max ? parseInt(fields.hr_max) : null,
        pace: fields.pace || null,
      };

      audioFile = files.audio || null;

    } else if (contentType.includes('application/json')) {
      // Fallback: texto directo sin audio
      const body = JSON.parse(req.body || '{}');
      metadata = body.metadata || {};
      transcription = body.text || '';
    }

    // 1. TRANSCRIPCIÓN CON WHISPER (si hay audio)
    if (audioFile && !transcription) {
      const { Blob } = await import('buffer');

      // Crear un File-like object para la API de OpenAI
      const audioBlob = new File(
        [audioFile.buffer],
        `audio.${audioFile.ext || 'webm'}`,
        { type: audioFile.mimetype || 'audio/webm' }
      );

      const whisperResponse = await openai.audio.transcriptions.create({
        file: audioBlob,
        model: 'whisper-1',
        language: 'es',
        response_format: 'text',
      });

      transcription = whisperResponse;
    }

    // Combinar transcripción con notas de texto si existen
    const fullInput = [
      transcription,
      metadata.notes_raw
    ].filter(Boolean).join('\n\n');

    if (!fullInput.trim()) {
      return res.status(400).json({ error: 'No hay contenido para analizar' });
    }

    // Construir mensaje para Claude con contexto
    const userMessage = `Transcripción del audio del atleta:
"${fullInput}"

Metadatos registrados en la app:
- Tipo de actividad: ${metadata.activity_type || 'no especificado'}
- Esfuerzo percibido (RPE): ${metadata.effort_rpe || 'no especificado'}
- Horas de sueño: ${metadata.sleep_hours || 'no especificado'}
- Calidad del sueño: ${metadata.sleep_quality ? metadata.sleep_quality + '/5' : 'no especificado'}
${metadata.duration_min ? `- Duración: ${metadata.duration_min} min` : ''}
${metadata.distance_km ? `- Distancia: ${metadata.distance_km} km` : ''}
${metadata.elevation_m ? `- Desnivel: ${metadata.elevation_m} m` : ''}
${metadata.hr_avg ? `- FC media: ${metadata.hr_avg} bpm` : ''}`;

    // 2. ANÁLISIS CON CLAUDE
    const claudeResponse = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: userMessage }],
    });

    const rawText = claudeResponse.content[0].text.trim();

    // Parsear JSON de Claude
    let analysis;
    try {
      analysis = JSON.parse(rawText);
    } catch {
      // Intentar extraer JSON si viene con texto extra
      const match = rawText.match(/\{[\s\S]*\}/);
      if (match) {
        analysis = JSON.parse(match[0]);
      } else {
        throw new Error('Claude no devolvió JSON válido');
      }
    }

    // 3. GUARDAR EN SUPABASE
    const sessionData = {
      // Metadatos del formulario (tienen prioridad sobre lo inferido por Claude)
      activity_type: metadata.activity_type || analysis.activity_type,
      effort_rpe: metadata.effort_rpe || analysis.effort_rpe,
      sleep_hours: metadata.sleep_hours,
      sleep_quality: metadata.sleep_quality,
      duration_min: metadata.duration_min || analysis.duration_min,
      distance_km: metadata.distance_km || analysis.distance_km,
      elevation_m: metadata.elevation_m || analysis.elevation_m,
      hr_avg: metadata.hr_avg,
      hr_max: metadata.hr_max,
      pace: metadata.pace,

      // Texto
      notes_raw: metadata.notes_raw,
      transcription: transcription || null,

      // Análisis de Claude
      physical_feelings: analysis.physical_feelings,
      mental_feelings: analysis.mental_feelings,
      claude_analysis: analysis.analysis,
      next_session_rec: analysis.next_session_rec,
      recovery_rec: analysis.recovery_rec,
      session_note: analysis.session_note,
    };

    const { data: savedSession, error: dbError } = await supabase
      .from('sessions')
      .insert(sessionData)
      .select()
      .single();

    if (dbError) {
      console.error('Supabase error:', dbError);
      // No falla: devuelve el análisis aunque no se guarde
    }

    // 4. RESPUESTA AL FRONTEND
    return res.status(200).json({
      success: true,
      session_id: savedSession?.id || null,
      transcription,
      analysis,
    });

  } catch (err) {
    console.error('Error en /api/session:', err);
    return res.status(500).json({
      error: err.message || 'Error interno del servidor',
    });
  }
}
