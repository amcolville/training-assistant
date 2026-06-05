#!/bin/bash
# Ejecutar desde dentro del repositorio clonado:
# git clone https://github.com/amcolville/training-assistant
# cd training-assistant
# bash setup_repo.sh

set -e

mkdir -p docs prompts templates athlete

# ── README.md ──────────────────────────────────────────────────────────────
cat > README.md << 'EOF'
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
EOF

# ── docs/proyecto_asistente_entrenamiento.md ───────────────────────────────
cat > docs/proyecto_asistente_entrenamiento.md << 'EOF'
# Proyecto: Asistente Personal de Entrenamiento

> Documento de referencia completo. Agnóstico al atleta — cada instancia requiere configurar
> el objetivo y aportar los documentos de referencia individuales descritos en la sección 2.

---

## 1. System prompt

```
Eres un asistente personal de entrenamiento y registro deportivo. Tu función es ayudar al atleta
a registrar, analizar y reflexionar sobre entrenamientos, resultados y estado físico/mental.
El objetivo de rendimiento — disciplina, distancia, desnivel, fecha — debe estar definido en
el contexto del atleta antes de iniciar el seguimiento.

**No elabores planes de entrenamiento.** Si el atleta necesita uno, lo aportará. Tu rol es
registro, análisis y acompañamiento.

## Contexto del atleta

Antes de comenzar el seguimiento, el atleta debe definir:

- **Objetivo principal:** disciplina, distancia/formato, desnivel si aplica, fecha.
- **Períodos de carga especiales:** bloques de montaña, expediciones, campamentos, viajes previstos.
- **Entrenadores activos:** si hay entrenador de trail, escalada u otra disciplina, el asistente
  respeta su trabajo. No lo cuestiona ni lo sustituye; registra y reflexiona sobre ello.
- **Disciplinas activas:** trail running, alpinismo, escalada en roca, fuerza, ciclismo u otras.

## Documentos de referencia

**`radiografia_entrenamiento_[atleta].md`**
Historial completo del atleta en Strava. Úsalo para contextualizar sesiones, comparar con períodos
equivalentes de años anteriores e identificar si la carga se aleja del rango habitual.

**`patrones_rendimiento_[atleta].md`**
Patrones que han funcionado antes de carreras objetivo. Úsalo para evaluar si la preparación
actual sigue esos patrones y para informar la recomendación de la siguiente sesión.

Nómbralos explícitamente cuando algo en el registro sea relevante para ellos.

## Fuentes de datos

El atleta puede subir archivos JSON del dispositivo GPS. Si el MCP de Strava está conectado,
úsalo como fuente primaria. Si ambas fuentes están disponibles, prioriza Strava para métricas
objetivas y el JSON para datos adicionales.

## Cuando reciba una actualización

1. Resume lo que se ha contado de forma estructurada.
2. Registra la sesión: tipo, duración/distancia, esfuerzo percibido, sensaciones físicas y mentales.
3. Cruza con datos de Strava o JSON si están disponibles.
4. Haz una sola pregunta si falta algo importante.
5. Reflexión breve sobre la sesión en relación al objetivo.
6. **Recomendación para la siguiente sesión:** concreta, basada en el plan del atleta, la fatiga
   observada y sus patrones históricos. No inventes carga; si no tienes el plan, pregunta.

## Registro semanal (lunes–domingo)

- Resumen de carga: horas, km y D+ por disciplina.
- Sensaciones: previas, durante y después.
- Hitos destacados.
- Observaciones para la semana siguiente.
- Cuenta atrás al objetivo cuando sea relevante.

## Tono

Español. Directo y cercano, como un compañero de montaña con criterio. Sin lenguaje motivacional
vacío. Si hay fatiga acumulada o molestias recurrentes, nómbralo. Ante la duda, una pregunta
bien hecha antes que un análisis basado en suposiciones.

Respuestas concisas. Si necesita más espacio, divide en partes numeradas y avisa con "→ continúa".
```

---

## 2. Documentos de referencia por atleta

### 2.1 `radiografia_entrenamiento_[atleta].md`

Análisis exhaustivo del historial de Strava: totales all-time, mapa de carga anual, evolución
técnica, top actividades, análisis de cada carrera objetivo completada, comparativa del período
en curso vs. años anteriores y diagnóstico actual.

Actualizar al inicio de cada temporada o tras un hito relevante.

### 2.2 `patrones_rendimiento_[atleta].md`

Patrones derivados de las carreras objetivo completadas: carreras intermedias como activadores,
largos en % de la distancia objetivo, D+ semanal en el bloque previo, estructura del tapering,
FC media como indicador, decisiones en condiciones adversas y efecto de bloques especiales.

Actualizar tras cada carrera objetivo completada.

---

## 3. Conectividad con Strava (MCP)

Strava es la fuente primaria de datos objetivos. Con el MCP conectado el asistente recupera
actividades automáticamente y cruza en tiempo real lo verbal con los datos objetivos.

URL del servidor MCP: `https://mcp.strava.com/mcp`

Sin MCP activo: el atleta sube archivos del dispositivo o describe la sesión verbalmente.

---

## 4. Formatos estándar

- Resumen diario → `templates/resumen_diario.md`
- Resumen semanal → `templates/resumen_semanal.md`
EOF

# ── docs/architecture.md ───────────────────────────────────────────────────
cat > docs/architecture.md << 'EOF'
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
EOF

# ── prompts/system_prompt.md ───────────────────────────────────────────────
cat > prompts/system_prompt.md << 'EOF'
# System Prompt — Asistente Personal de Entrenamiento

> Cargar como instrucción de sistema en Claude.ai al iniciar una sesión de seguimiento.

---

```
Eres un asistente personal de entrenamiento y registro deportivo. Tu función es ayudar al atleta
a registrar, analizar y reflexionar sobre entrenamientos, resultados y estado físico/mental.
El objetivo de rendimiento — disciplina, distancia, desnivel, fecha — debe estar definido en
el contexto del atleta antes de iniciar el seguimiento.

**No elabores planes de entrenamiento.** Si el atleta necesita uno, lo aportará. Tu rol es
registro, análisis y acompañamiento.

## Contexto del atleta

- **Objetivo principal:** disciplina, distancia/formato, desnivel si aplica, fecha.
- **Períodos de carga especiales:** bloques de montaña, expediciones, campamentos, viajes previstos.
- **Entrenadores activos:** el asistente respeta su trabajo. No lo cuestiona ni lo sustituye.
- **Disciplinas activas:** trail running, alpinismo, escalada en roca, fuerza, ciclismo u otras.

## Documentos de referencia

**`radiografia_entrenamiento_[atleta].md`** — historial Strava. Úsalo para contextualizar
sesiones y comparar con períodos equivalentes de años anteriores.

**`patrones_rendimiento_[atleta].md`** — patrones que han funcionado antes de carreras objetivo.
Úsalo para evaluar la preparación actual e informar la recomendación de la siguiente sesión.

Nómbralos explícitamente cuando algo en el registro sea relevante para ellos.

## Fuentes de datos

Si el MCP de Strava está conectado, úsalo como fuente primaria. Si hay JSON del dispositivo,
úsalo para datos adicionales que Strava no recoja.

## Cuando reciba una actualización

1. Resume lo que se ha contado de forma estructurada.
2. Registra la sesión: tipo, duración/distancia, esfuerzo percibido, sensaciones físicas y mentales.
3. Cruza con datos de Strava o JSON si están disponibles.
4. Haz una sola pregunta si falta algo importante.
5. Reflexión breve sobre la sesión en relación al objetivo.
6. **Recomendación para la siguiente sesión:** concreta, basada en el plan, la fatiga observada
   y los patrones históricos. No inventes carga; si no tienes el plan, pregunta.

## Registro semanal (lunes–domingo)

Resumen de carga · Sensaciones (previas, durante, después) · Hitos · Observaciones semana siguiente
· Cuenta atrás al objetivo cuando sea relevante.

## Tono

Español. Directo y cercano, como un compañero de montaña con criterio. Sin motivacional vacío.
Si hay fatiga acumulada o molestias recurrentes, nómbralo. Ante la duda, pregunta antes que suponer.

Respuestas concisas. Si necesita más espacio, divide en partes y avisa con "→ continúa".
```
EOF

# ── templates/radiografia_entrenamiento.md ────────────────────────────────
cat > templates/radiografia_entrenamiento.md << 'EOF'
# Radiografía de Entrenamiento — [ATLETA]

> Generado a partir del historial de Strava.
> Actualizar al inicio de cada temporada o tras un hito relevante.

---

## 1. Visión global

| Disciplina | Actividades | Km totales | D+ total | Horas totales |
|---|---|---|---|---|
| Trail / Running | — | — | — | — |
| Alpinismo | — | — | — | — |
| Ciclismo | — | — | — | — |
| Escalada | — | — | — | — |
| **TOTAL** | — | — | — | — |

---

## 2. Mapa de carga anual

| Año | Km totales | D+ total | Horas | Hito principal |
|---|---|---|---|---|
| 20XX | — | — | — | — |

---

## 3. Evolución técnica y progresión

### Hitos de distancia

| Hito | Fecha | Actividad |
|---|---|---|
| Primera vez >20 km | — | — |
| Primera vez >50 km | — | — |
| Primera vez >100 km | — | — |

### Hitos de desnivel

| Hito | Fecha | Actividad |
|---|---|---|
| Primera vez >1.000 m D+ | — | — |
| Primera vez >2.000 m D+ | — | — |
| Primera vez >3.000 m D+ | — | — |

### Altitud máxima alcanzada

| Fecha | Altitud | Actividad |
|---|---|---|
| — | — m | — |

---

## 4. Top actividades

### Por distancia

| # | Fecha | Actividad | Km | D+ | Tiempo |
|---|---|---|---|---|---|
| 1 | — | — | — | — | — |

### Por desnivel

| # | Fecha | Actividad | D+ | Km | Tiempo |
|---|---|---|---|---|---|
| 1 | — | — | — | — | — |

---

## 5. Carreras objetivo completadas

### [Nombre de la carrera] — [Fecha]

**Datos de carrera:** distancia / D+ / tiempo / posición (si aplica)

**Bloque previo (8 semanas):**

| Semana | Km | D+ | Sesiones clave |
|---|---|---|---|
| −8 | — | — | — |
| −7 | — | — | — |
| −6 | — | — | — |
| −5 | — | — | — |
| −4 | — | — | — |
| −3 | — | — | — |
| −2 | — | — | — |
| −1 (tapering) | — | — | — |

**Patrón identificado:** —

---

## 6. Comparativa período en curso vs. años anteriores

| Período | Año actual | Año anterior | Año −2 |
|---|---|---|---|
| Ene–Mar | — km / — D+ | — km / — D+ | — km / — D+ |
| Abr–Jun | — km / — D+ | — km / — D+ | — km / — D+ |
| Jul–Sep | — km / — D+ | — km / — D+ | — km / — D+ |
| Oct–Dic | — km / — D+ | — km / — D+ | — km / — D+ |

---

## 7. Diagnóstico actual

**Fortalezas del historial:**
- —

**Gaps o áreas de desarrollo:**
- —

**Observaciones de cara al objetivo en curso:**
- —
EOF

# ── templates/patrones_rendimiento.md ─────────────────────────────────────
cat > templates/patrones_rendimiento.md << 'EOF'
# Patrones de Rendimiento — [ATLETA]

> Actualizar tras cada carrera objetivo completada.

---

## 1. Carreras intermedias como activadores

| Carrera objetivo | Carreras intermedias previas | Resultado |
|---|---|---|
| — | — | — |

**Lectura:** —

**Aplicación al objetivo en curso:** —

---

## 2. Largos en % de la distancia objetivo

| Carrera objetivo | Distancia | Larguísimo máximo | % sobre objetivo | Semanas antes |
|---|---|---|---|---|
| — | — km | — km | —% | — |

**Lectura:** —

**Aplicación al objetivo en curso:** —

---

## 3. D+ semanal en el bloque previo

| Carrera objetivo | D+ carrera | Media semanal bloque | % | Semana pico | % |
|---|---|---|---|---|---|
| — | — m | — m | —% | — m | —% |

**Lectura:** —

**Aplicación al objetivo en curso:** —

---

## 4. Estructura del tapering

| Carrera objetivo | Días de tapering | Sesiones en tapering | Resultado |
|---|---|---|---|
| — | — | — | — |

**Lectura:** —

**Aplicación al objetivo en curso:** —

---

## 5. FC media como indicador de gestión aeróbica

| Carrera | Año | Distancia | FC media | Ritmo medio | Observación |
|---|---|---|---|---|---|
| — | — | — km | — bpm | — min/km | — |

**Banda objetivo:** — bpm

**Lectura:** —

---

## 6. Toma de decisiones en condiciones adversas

| Carrera | Condición adversa | Decisión tomada | Resultado |
|---|---|---|---|
| — | — | — | — |

**Lectura:** —

---

## 7. Efecto de bloques especiales

| Bloque especial | Fecha | Descripción | Impacto observado |
|---|---|---|---|
| — | — | — | — |

**Lectura:** —

---

## Síntesis

- **Lo que siempre funciona:** —
- **Lo que nunca funciona:** —
- **Variable clave a monitorizar:** —
EOF

# ── templates/resumen_diario.md ────────────────────────────────────────────
cat > templates/resumen_diario.md << 'EOF'
# Resumen Diario — Plantilla

---

## RESUMEN DIARIO — [Fecha] · [Tipo de actividad]

---

### ACTIVIDAD

| Campo | Valor |
|---|---|
| Tipo | Trail / Alpinismo / Escalada / Fuerza / Descanso activo |
| Distancia | X,X km |
| D+ / D- | X.XXX m / X.XXX m |
| Duración | Xh XXmin |
| Altitud máxima | X.XXX m *(si aplica)* |
| FC media / máxima | XXX / XXX bpm *(si disponible)* |
| Ritmo medio | X:XX min/km *(si aplica)* |
| Zonas de potencia | Z1: X% · Z2: X% · Z3: X% · Z4: X% · Z5: X% *(si disponible)* |

---

### SENSACIONES

**Físicas:** piernas, respiración, molestias, energía general.

**Mentales:** motivación, disfrute, concentración, momentos clave.

**Esfuerzo percibido:** X/10

---

### SUEÑO (noche previa)

| Campo | Valor |
|---|---|
| Total | Xh XXmin |
| vs. objetivo | +/− XX min |
| HRV | XX ms *(si disponible)* |
| Calidad | XX% *(si disponible)* |
| Notas | — |

---

### RECOMENDACIONES

**Pre-entreno (próxima sesión):** indicación concreta — intensidad, duración, gestión del esfuerzo.

**Post-entreno (recuperación):** nutrición, sueño, movilidad, descanso activo.

---

### NOTA

*Observación concisa si algo conecta con el historial, los patrones históricos o la cuenta atrás
al objetivo. Si no hay nada relevante, esta sección se omite.*
EOF

# ── templates/resumen_semanal.md ───────────────────────────────────────────
cat > templates/resumen_semanal.md << 'EOF'
# Resumen Semanal — Plantilla

> Si la semana está en curso: "semana en curso — datos hasta [día]".

---

## SEMANA [DD–DD mes AAAA] · [X semanas para el objetivo]

---

### DESGLOSE DE ACTIVIDAD

| Disciplina | Sesiones | Distancia | D+ | Tiempo en movimiento |
|---|---|---|---|---|
| Trail | X | X,X km | X.XXX m | Xh XXmin |
| Alpinismo | X | X,X km | X.XXX m | Xh XXmin |
| Escalada / Fuerza | X | — | — | ~Xh |
| Ciclismo | X | X,X km | X.XXX m | Xh XXmin |
| **TOTAL** | **X** | **X,X km** | **X.XXX m** | **~Xh XXmin** |

*Incluir solo disciplinas activas esa semana.*

---

### SUEÑO

| Fecha | Total | vs. objetivo | HRV | Notas |
|---|---|---|---|---|
| Lunes | Xh XXmin | +/− XX min | XX ms | — |
| Martes | Xh XXmin | +/− XX min | XX ms | — |
| Miércoles | Xh XXmin | +/− XX min | XX ms | — |
| Jueves | Xh XXmin | +/− XX min | XX ms | — |
| Viernes | Xh XXmin | +/− XX min | XX ms | — |
| Sábado | Xh XXmin | +/− XX min | XX ms | — |
| Domingo | Xh XXmin | +/− XX min | XX ms | — |
| **Media** | **Xh XXmin** | **+/− XX min** | **XX ms** | |

*HRV: omitir columna si el atleta no dispone de ese dato.*

---

### SENSACIONES MEDIAS

**Inicio de semana:** fatiga arrastrada, motivación, estado físico.

**Durante la semana:** energía general, momentos de alta y baja, molestias, respuesta a la carga.

**Cierre de semana:** recuperación, sensación subjetiva de progreso, estado físico y mental al final.

---

### HITOS

*Marcas personales, primeras veces, sesiones clave, decisiones tácticas, progresiones técnicas.*

---

### INSIGHTS

*Observaciones analíticas del cruce entre datos, sensaciones e historial. Lo que los números
solos no cuentan: divergencia FC/esfuerzo percibido, señales de fatiga no verbalizadas,
coherencia o desviación respecto a patrones históricos.*

---

### RECOMENDACIONES PARA LA SEMANA SIGUIENTE

*Qué priorizar, qué moderar, qué vigilar. Enmarcado en el plan del entrenador si lo hay.*
EOF

# ── athlete/README.md ──────────────────────────────────────────────────────
cat > athlete/README.md << 'EOF'
# Configuración de un atleta nuevo

---

## Paso 1 — Genera los documentos de referencia

```bash
cp ../templates/radiografia_entrenamiento.md radiografia_entrenamiento_[nombre].md
cp ../templates/patrones_rendimiento.md patrones_rendimiento_[nombre].md
```

Para la radiografía: exporta el historial de Strava y analiza volumen anual, progresión y
carreras objetivo con sus bloques previos.

Para los patrones: cruza los bloques previos a cada carrera objetivo con el resultado.

---

## Paso 2 — Define el contexto del atleta

Crea `contexto_[nombre].md`:

```markdown
# Contexto — [Nombre]

## Objetivo principal
- Disciplina:
- Distancia / formato:
- Desnivel (si aplica):
- Fecha:

## Períodos especiales previstos
-

## Entrenadores activos
-

## Disciplinas activas
-
```

---

## Paso 3 — Conecta Strava (recomendado)

En Claude.ai, activa el conector de Strava. URL MCP: `https://mcp.strava.com/mcp`

---

## Paso 4 — Carga el system prompt

Copia `/prompts/system_prompt.md` como instrucción de sistema en Claude.ai y adjunta:
- `radiografia_entrenamiento_[nombre].md`
- `patrones_rendimiento_[nombre].md`
- `contexto_[nombre].md`

---

## Estructura

```
athlete/
├── radiografia_entrenamiento_[nombre].md
├── patrones_rendimiento_[nombre].md
└── contexto_[nombre].md
```

> Los archivos de atleta están en `.gitignore` si contienen datos personales.
EOF

# ── .gitignore ─────────────────────────────────────────────────────────────
cat > .gitignore << 'EOF'
# Archivos de atleta con datos personales
athlete/radiografia_entrenamiento_*.md
athlete/patrones_rendimiento_*.md
athlete/contexto_*.md

# Excepción
!athlete/README.md

# Sistema operativo
.DS_Store
Thumbs.db

# Editores
.vscode/
.idea/
*.swp
EOF

git add .
git commit -m "chore: initial project structure"
git push origin main

echo "✅ Repositorio configurado correctamente."
