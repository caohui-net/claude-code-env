# Lightpanda Browser 使用指南

## 安装信息

- **版本**: 1.0.0-nightly.5982+47041859
- **安装路径**: `/usr/local/bin/lightpanda`
- **安装日期**: 2026-05-02

## 基本使用

### 1. CLI 工具

#### 抓取网页内容

```bash
# 抓取 HTML
lightpanda fetch --dump html https://example.com

# 转换为 Markdown
lightpanda fetch --dump markdown https://example.com

# 遵守 robots.txt
lightpanda fetch --obey-robots --dump html https://example.com

# 等待特定元素
lightpanda fetch --wait-selector ".content" --dump html https://example.com

# 等待网络空闲
lightpanda fetch --wait-until networkidle0 --dump html https://example.com

# 等待指定时间（毫秒）
lightpanda fetch --wait-ms 3000 --dump html https://example.com
```

#### 启动 CDP 服务器

```bash
# 启动服务器（默认端口 9222）
lightpanda serve --host 127.0.0.1 --port 9222

# 带日志
lightpanda serve --log-format pretty --log-level info --host 127.0.0.1 --port 9222

# 遵守 robots.txt
lightpanda serve --obey-robots --host 127.0.0.1 --port 9222
```

### 2. MCP 服务器集成

#### 配置文件

项目已配置 MCP 服务器：`.mcp.json`

```json
{
  "mcpServers": {
    "lightpanda": {
      "command": "/usr/local/bin/lightpanda",
      "args": ["mcp"]
    }
  }
}
```

#### 使用 MCP 工具

在 Claude Code 中，Lightpanda MCP 服务器提供的工具会自动可用。

### 3. Puppeteer 集成

#### 安装依赖

```bash
npm install puppeteer-core
```

#### 示例代码

```javascript
import puppeteer from 'puppeteer-core';

// 连接到 Lightpanda CDP 服务器
const browser = await puppeteer.connect({
  browserWSEndpoint: "ws://127.0.0.1:9222",
});

const context = await browser.createBrowserContext();
const page = await context.newPage();

// 导航到页面
await page.goto('https://example.com', {
  waitUntil: "networkidle0"
});

// 提取数据
const links = await page.evaluate(() => {
  return Array.from(document.querySelectorAll('a')).map(a => ({
    href: a.getAttribute('href'),
    text: a.textContent.trim()
  }));
});

console.log(links);

// 清理
await page.close();
await context.close();
await browser.disconnect();
```

## 与 Claude Code 环境集成

### 场景 1：AI 代理 Web 自动化

使用 OMC 编排多个代理执行 Web 任务：

```bash
# 启动 Lightpanda CDP 服务器
lightpanda serve --host 127.0.0.1 --port 9222 &

# 在 Claude Code 中使用 Puppeteer 脚本
# 或通过 MCP 工具调用
```

### 场景 2：内容抓取和转换

```bash
# 抓取技术文档并转换为 Markdown
lightpanda fetch --dump markdown https://docs.example.com > output.md

# 批量抓取
for url in $(cat urls.txt); do
  lightpanda fetch --dump markdown "$url" > "$(echo $url | md5sum | cut -d' ' -f1).md"
done
```

### 场景 3：与 market-research skill 配合

```javascript
// 使用 Lightpanda 抓取竞品网站
// 配合 market-research skill 分析数据
const browser = await puppeteer.connect({
  browserWSEndpoint: "ws://127.0.0.1:9222"
});

// 抓取竞品信息
const competitors = ['https://competitor1.com', 'https://competitor2.com'];
const data = [];

for (const url of competitors) {
  const page = await browser.newPage();
  await page.goto(url);
  
  const info = await page.evaluate(() => ({
    title: document.title,
    description: document.querySelector('meta[name="description"]')?.content,
    // 更多数据提取...
  }));
  
  data.push({ url, ...info });
  await page.close();
}

// 数据传递给 market-research skill 分析
```

### 场景 4：与 claude-mem 协同

```bash
# 抓取前查询 claude-mem 是否已有缓存
# 抓取后存储到 claude-mem
# 避免重复抓取
```

## 性能优势

相比 Headless Chrome：

| 指标 | Lightpanda | Headless Chrome | 优势 |
|------|------------|-----------------|------|
| 内存占用 (100页) | 123MB | 2GB | ~16倍更少 |
| 执行时间 (100页) | 5s | 46s | ~9倍更快 |

## 限制和注意事项

### 当前限制

1. **Beta 阶段** - 可能遇到错误或崩溃
2. **Web API 覆盖不完整** - 部分复杂网站可能不支持
3. **CORS 未实现** - 跨域请求受限
4. **无图形渲染** - 不支持截图

### 适用场景

✅ **适合**
- 大规模网页抓取
- 简单的 Web 自动化
- 文档和内容提取
- 资源受限环境

❌ **不适合**
- 需要完整 Web API 的复杂应用
- 需要截图的场景
- 需要 CORS 支持的场景

## 故障排查

### 问题 1：连接 CDP 服务器失败

```bash
# 检查服务器是否运行
ps aux | grep lightpanda

# 检查端口是否被占用
lsof -i :9222

# 重启服务器
pkill lightpanda
lightpanda serve --host 127.0.0.1 --port 9222
```

### 问题 2：MCP 服务器无响应

```bash
# 检查 .mcp.json 配置
cat .mcp.json

# 验证 lightpanda 可执行
/usr/local/bin/lightpanda version

# 重启 Claude Code 会话
```

### 问题 3：网页加载失败

```bash
# 增加等待时间
lightpanda fetch --wait-ms 5000 --dump html https://example.com

# 使用不同的等待策略
lightpanda fetch --wait-until networkidle0 --dump html https://example.com
```

## 更多资源

- **官方文档**: https://lightpanda.io/docs
- **GitHub**: https://github.com/lightpanda-io/browser
- **Agent Skill**: https://github.com/lightpanda-io/agent-skill
- **Discord**: https://discord.gg/K63XeymfB5

## 下一步

1. 测试 MCP 集成
2. 创建自定义 Web 自动化脚本
3. 与 OMC skills 集成
4. 探索高级用例
