# Training Assistant

Asistente personal de entrenamiento y registro deportivo basado en Claude.

No es una aplicación de planes de entrenamiento. Es un sistema de **seguimiento, análisis y acompañamiento** centrado en las sensaciones del atleta, los datos objetivos y los patrones históricos de rendimiento.

---

## Estructura del repositorio

```
training-assistant/
├── docs/
│   ├── proyecto_asistente_entrenamiento.md
│   └── architecture.md
├── prompts/
│   └── system_prompt.md
├── templates/
│   ├── radiografia_entrenamiento.md
│   ├── patrones_rendimiento.md
│   ├── resumen_diario.md
│   └── resumen_semanal.md
├── athlete/
│   └── README.md
└── README.md
```

---

## Cómo funciona

1. **Configura el contexto del atleta** — objetivo, disciplinas activas, entrenadores, períodos especiales.
2. **Genera los documentos de referencia** — `radiografia_entrenamiento_[atleta].md` y `patrones_rendimiento_[atleta].md` a partir del historial de Strava.
3. **Conecta Strava (MCP)** — opcional pero recomendado.
4. **Registra sesiones** — verbalmente, con archivos JSON/FIT del dispositivo GPS, o vía Strava.
5. **Obtén análisis y recomendaciones** — resumen diario, resumen semanal, recomendación para la siguiente sesión.

---

## Fuentes de datos soportadas

| Fuente | Tipo | Notas |
|---|---|---|
| Strava MCP | Primaria | Actividades automáticas con métricas completas |
| JSON / FIT del dispositivo | Complementaria | Suunto, Garmin, Coros |
| Registro verbal | Siempre disponible | Sensaciones, contexto, decisiones |

---

## Requisitos para empezar

- Cuenta de Claude.ai (Pro o superior recomendado)
- Historial de Strava exportado (para generar la radiografía inicial)
- Conexión del MCP de Strava en Claude.ai (opcional): `https://mcp.strava.com/mcp`
