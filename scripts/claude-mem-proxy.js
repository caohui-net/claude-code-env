#!/usr/bin/env node
/**
 * Claude Memory Web Viewer Proxy
 *
 * 默认监听 127.0.0.1:38888，转发到 127.0.0.1:37777
 *
 * 环境变量:
 *   CLAUDE_MEM_HOST        - 监听地址 (默认: 127.0.0.1)
 *   CLAUDE_MEM_PORT        - 监听端口 (默认: 38888)
 *   CLAUDE_MEM_TARGET_HOST - 目标地址 (默认: 127.0.0.1)
 *   CLAUDE_MEM_TARGET_PORT - 目标端口 (默认: 37777)
 *
 * 远程访问 (不推荐):
 *   CLAUDE_MEM_HOST=0.0.0.0 node scripts/claude-mem-proxy.js
 *   建议使用 SSH tunnel 代替
 */

const http = require('http');
const httpProxy = require('http-proxy');

// 配置
const host = process.env.CLAUDE_MEM_HOST || '127.0.0.1';
const port = Number(process.env.CLAUDE_MEM_PORT || 38888);
const targetHost = process.env.CLAUDE_MEM_TARGET_HOST || '127.0.0.1';
const targetPort = Number(process.env.CLAUDE_MEM_TARGET_PORT || 37777);

// 安全警告
if (host === '0.0.0.0') {
  console.warn('⚠️  警告: 监听 0.0.0.0 会暴露服务到网络');
  console.warn('⚠️  建议使用 SSH tunnel 进行远程访问');
  console.warn('⚠️  或者配置防火墙限制访问');
}

// 创建代理
const proxy = httpProxy.createProxyServer({
  target: `http://${targetHost}:${targetPort}`
});

// 创建服务器
const server = http.createServer((req, res) => {
  proxy.web(req, res);
});

// 错误处理
proxy.on('error', (err, req, res) => {
  console.error('代理错误:', err.message);
  res.writeHead(502, { 'Content-Type': 'text/plain' });
  res.end('Bad Gateway: 无法连接到 claude-mem');
});

// 启动服务器
server.listen(port, host, () => {
  console.log(`✅ Claude Memory Proxy 运行中`);
  console.log(`   监听: http://${host}:${port}`);
  console.log(`   转发: http://${targetHost}:${targetPort}`);
  console.log(`   按 Ctrl+C 停止`);
});
