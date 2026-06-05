# Arquitectura del proyecto

## Visión general

Sistema de seguimiento personalizado construido sobre Claude. No genera planes — analiza lo que
el atleta hace, cómo se siente y qué ha funcionado en el pasado para dar recomendaciones concretas.

---

## Capas del sistema

```
ATLETA
  Registra sesiones · Describe sensaciones · Hace preguntas · Aporta plan
        │
FUENTES DE DATOS
  Strava MCP (primaria) · JSON/FIT del dispositivo (complementaria) · Verbal (siempre)
        │
DOCUMENTOS DE CONTEXTO
  radiografia_entrenamiento_[atleta].md  →  historial objetivo
  patrones_rendimiento_[atleta].md       →  qué ha funcionado antes
        │
ASISTENTE (Claude)
  · Registra y cruza datos
  · Detecta patrones y desviaciones
  · Genera resúmenes diarios y semanales
  · Recomienda cómo afrontar la siguiente sesión
  · Señala señales de fatiga, lesión o queme
```

---

## Flujo de una sesión

1. Atleta registra sesión (verbal / Strava / JSON)
2. Asistente extrae métricas objetivas
3. Asistente cruza con sensaciones verbalizadas
4. Asistente contrasta con historial y patrones
5. Asistente genera resumen + recomendación siguiente sesión

---

## Flujo de una semana

1. Sesiones acumuladas lunes–domingo
2. Atleta pide resumen semanal
3. Asistente agrega carga total por disciplina
4. Asistente evalúa sensaciones medias y hitos
5. Asistente contrasta semana vs. patrones históricos
6. Asistente genera recomendaciones para la semana siguiente

---

## Decisiones de diseño

| Decisión | Justificación |
|---|---|
| No genera planes | El asistente complementa al entrenador, no lo reemplaza |
| Semana calendario (L-D) | Facilita la comparación entre semanas y con Strava |
| Strava como fuente primaria | Datos objetivos sin fricción de entrada manual |
| Documentos por atleta | El sistema es personalizable e independiente por atleta |
| Tono directo | El atleta de rendimiento necesita criterio, no elogios genéricos |

---

## Roadmap técnico

- [ ] Interfaz web ligera para registro de sensaciones diarias
- [ ] Generación automática de radiografía desde export de Strava
- [ ] Dashboard semanal con evolución de métricas
- [ ] Alertas proactivas de fatiga acumulada o molestias recurrentes
- [ ] Soporte multi-atleta con perfiles separados
