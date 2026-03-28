#!/usr/bin/env node
const http = require('http');
const PORT = process.argv[2] || 38888;

const server = http.createServer((req, res) => {
  const options = {
    hostname: '127.0.0.1',
    port: 37777,
    path: req.url,
    method: req.method,
    headers: req.headers
  };

  const proxyReq = http.request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err.message);
    res.writeHead(502);
    res.end('Bad Gateway');
  });

  req.pipe(proxyReq);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Proxy: http://0.0.0.0:${PORT} -> http://127.0.0.1:37777`);
});
