#!/bin/bash
# Ejecutar desde dentro del repositorio clonado:
# cd training-assistant
# bash push_app.sh

set -e

# Copiar los archivos del diseño con los nombres correctos
# IMPORTANTE: ajusta la ruta si los .html están en otro lugar

# index.html — login (apunta a app.html)
# app.html   — app principal (3 secciones)
# logo-directions.html — exploración de logo

# Si tienes los archivos del zip a mano, cópialos así:
# cp "JRNL Login.html" index.html
# cp "JRNL.html" app.html
# cp "JRNL Logo Directions.html" logo-directions.html

# Corregir el enlace del login para que apunte a app.html
sed -i "s|window.location.href='JRNL.html'|window.location.href='app.html'|g" index.html 2>/dev/null || true

git add index.html app.html logo-directions.html
git commit -m "feat: add JRNL web app (login + main app + logo directions)"
git push origin main

echo "✅ App subida. Activa GitHub Pages en Settings → Pages → Branch: main / root"
