// lib/multipart.js
// Parser de multipart/form-data para Vercel serverless functions
// Sin dependencias externas — usa el buffer raw de la request

export async function parseMultipart(req) {
  return new Promise((resolve, reject) => {
    const contentType = req.headers['content-type'] || '';
    const boundaryMatch = contentType.match(/boundary=([^\s;]+)/);
    if (!boundaryMatch) {
      return reject(new Error('No boundary en multipart'));
    }

    const boundary = boundaryMatch[1];
    const chunks = [];

    req.on('data', chunk => chunks.push(chunk));
    req.on('end', () => {
      try {
        const buffer = Buffer.concat(chunks);
        const result = parseMultipartBuffer(buffer, boundary);
        resolve(result);
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

function parseMultipartBuffer(buffer, boundary) {
  const fields = {};
  const files = {};

  const delimiter = Buffer.from(`--${boundary}`);
  const parts = splitBuffer(buffer, delimiter);

  for (const part of parts) {
    if (!part || part.length < 4) continue;

    // Separar headers del body (doble CRLF)
    const headerEnd = indexOfCRLFCRLF(part);
    if (headerEnd === -1) continue;

    const headerBuffer = part.slice(0, headerEnd);
    const bodyBuffer = part.slice(headerEnd + 4);

    const headers = headerBuffer.toString('utf-8');
    const dispositionMatch = headers.match(/Content-Disposition:[^\r\n]*name="([^"]+)"/i);
    if (!dispositionMatch) continue;

    const fieldName = dispositionMatch[1];
    const filenameMatch = headers.match(/filename="([^"]+)"/i);
    const contentTypeMatch = headers.match(/Content-Type:\s*([^\r\n]+)/i);

    if (filenameMatch) {
      // Es un archivo
      const filename = filenameMatch[1];
      const mimetype = contentTypeMatch ? contentTypeMatch[1].trim() : 'application/octet-stream';
      const ext = filename.split('.').pop() || 'bin';

      // Quitar CRLF final si existe
      const fileBuffer = bodyBuffer.slice(-2).toString() === '\r\n'
        ? bodyBuffer.slice(0, -2)
        : bodyBuffer;

      files[fieldName] = { buffer: fileBuffer, filename, mimetype, ext };
    } else {
      // Es un campo de texto
      let value = bodyBuffer.toString('utf-8');
      if (value.endsWith('\r\n')) value = value.slice(0, -2);
      fields[fieldName] = value;
    }
  }

  return { fields, files };
}

function splitBuffer(buffer, delimiter) {
  const parts = [];
  let start = 0;

  while (true) {
    const idx = buffer.indexOf(delimiter, start);
    if (idx === -1) break;
    if (idx > start) {
      parts.push(buffer.slice(start, idx));
    }
    start = idx + delimiter.length;
    // Saltar CRLF después del boundary
    if (buffer[start] === 0x0d && buffer[start + 1] === 0x0a) start += 2;
    // Fin del multipart
    if (buffer[start] === 0x2d && buffer[start + 1] === 0x2d) break;
  }

  return parts;
}

function indexOfCRLFCRLF(buffer) {
  for (let i = 0; i < buffer.length - 3; i++) {
    if (buffer[i] === 0x0d && buffer[i+1] === 0x0a &&
        buffer[i+2] === 0x0d && buffer[i+3] === 0x0a) {
      return i;
    }
  }
  return -1;
}
