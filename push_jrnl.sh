#!/bin/bash
# Ejecutar desde la raíz del repo training-assistant
# bash ~/push_jrnl.sh  (ajusta la ruta si es necesario)

set -e
JRNL_DIR="$(dirname "$0")/jrnl"

echo "→ Copiando archivos JRNL al repositorio..."

mkdir -p api lib public

cp "$JRNL_DIR/api/session.js"   api/session.js
cp "$JRNL_DIR/api/sessions.js"  api/sessions.js
cp "$JRNL_DIR/api/weekly.js"    api/weekly.js
cp "$JRNL_DIR/lib/multipart.js" lib/multipart.js
cp "$JRNL_DIR/public/app.html"  public/app.html
cp "$JRNL_DIR/public/index.html" public/index.html
cp "$JRNL_DIR/package.json"     package.json
cp "$JRNL_DIR/vercel.json"      vercel.json
cp "$JRNL_DIR/supabase_schema.sql" supabase_schema.sql

echo "→ Commit y push..."
git add .
git commit -m "feat: JRNL full-stack app — voice input, Claude analysis, Supabase storage"
git push origin main

echo ""
echo "✅ Subido a GitHub."
echo ""
echo "AHORA:"
echo "1. Ejecuta supabase_schema.sql en Supabase SQL Editor"
echo "2. En Vercel > Settings > Environment Variables añade:"
echo "   ANTHROPIC_API_KEY"
echo "   OPENAI_API_KEY"
echo "   SUPABASE_URL      = https://almynvwwmqznvscdnhpx.supabase.co"
echo "   SUPABASE_SERVICE_KEY"
echo "3. Vercel redesplegará automáticamente"
echo "4. Accede a https://tu-proyecto.vercel.app/public/app.html"
