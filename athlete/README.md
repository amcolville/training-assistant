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
