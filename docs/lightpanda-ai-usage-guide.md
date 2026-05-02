# Lightpanda AI 使用指南

## 何时使用 Lightpanda MCP 工具

### 自动触发场景

AI 应在以下情况下**主动使用** Lightpanda MCP 工具：

#### 1. 网页内容提取
**触发关键词**：抓取、爬取、提取网页、获取网页内容、网页转 Markdown

**示例任务**：
- "帮我抓取 https://example.com 的内容"
- "提取这个网页的文本内容"
- "把这个网页转换成 Markdown"

**使用工具**：
- `mcp__lightpanda__goto` - 导航到目标网页
- `mcp__lightpanda__markdown` - 提取 Markdown 格式内容
- `mcp__lightpanda__semantic_tree` - 获取语义化 DOM 树

#### 2. 网页信息查询
**触发关键词**：查看网页、访问网站、检查网页、网页上有什么

**示例任务**：
- "看看 https://news.ycombinator.com 上有什么新闻"
- "访问这个网站并告诉我主要内容"
- "检查这个页面的标题和描述"

**使用工具**：
- `mcp__lightpanda__goto` + `mcp__lightpanda__markdown`
- `mcp__lightpanda__structuredData` - 提取结构化数据（JSON-LD, OpenGraph）

#### 3. 链接收集
**触发关键词**：收集链接、提取所有链接、找出页面上的链接

**示例任务**：
- "收集这个页面上的所有链接"
- "找出文档页面的所有子页面链接"

**使用工具**：
- `mcp__lightpanda__links` - 提取所有链接

#### 4. 表单分析
**触发关键词**：分析表单、表单有哪些字段、表单结构

**示例任务**：
- "分析这个网页的表单结构"
- "这个表单需要填写哪些字段"

**使用工具**：
- `mcp__lightpanda__detectForms` - 检测表单结构

#### 5. 交互式元素查找
**触发关键词**：找按钮、查找元素、页面上有哪些可点击的

**示例任务**：
- "找出页面上所有的按钮"
- "这个页面有哪些可交互的元素"

**使用工具**：
- `mcp__lightpanda__interactiveElements` - 提取交互元素
- `mcp__lightpanda__findElement` - 按角色/名称查找元素

#### 6. 市场研究和竞品分析
**触发关键词**：竞品分析、市场调研、收集竞品信息

**示例任务**：
- "帮我分析这几个竞品网站的特点"
- "收集这些公司网站的产品信息"

**使用工具**：
- 结合 `market-research` skill
- 批量使用 `mcp__lightpanda__goto` + `mcp__lightpanda__markdown`

### 不应使用的场景

❌ **不要使用 Lightpanda 的情况**：

1. **已有 API 可用** - 优先使用官方 API
2. **需要截图** - Lightpanda 不支持图形渲染
3. **复杂 Web 应用** - 可能遇到兼容性问题
4. **需要 CORS** - Lightpanda 未实现 CORS
5. **简单的 HTTP 请求** - 使用 `curl` 或 `WebFetch` 更轻量

### 工具选择决策树

```
用户请求涉及网页？
├─ 是 → 有官方 API？
│   ├─ 是 → 使用 API（不用 Lightpanda）
│   └─ 否 → 需要 JavaScript 渲染？
│       ├─ 是 → 使用 Lightpanda MCP 工具
│       └─ 否 → 使用 WebFetch 或 curl
└─ 否 → 不使用 Lightpanda
```

## 工具组合模式

### 模式 1：基础内容提取
```
1. mcp__lightpanda__goto(url)
2. mcp__lightpanda__markdown()
```

### 模式 2：结构化数据提取
```
1. mcp__lightpanda__goto(url)
2. mcp__lightpanda__structuredData()
```

### 模式 3：链接爬取
```
1. mcp__lightpanda__goto(url)
2. mcp__lightpanda__links()
3. 对每个链接重复步骤 1-2
```

### 模式 4：表单分析
```
1. mcp__lightpanda__goto(url)
2. mcp__lightpanda__detectForms()
```

### 模式 5：交互元素查找
```
1. mcp__lightpanda__goto(url)
2. mcp__lightpanda__findElement(role="button")
或
2. mcp__lightpanda__interactiveElements()
```

## 性能考虑

### 批量操作
- 对于多个 URL，顺序处理（Lightpanda 单实例）
- 每次导航后提取所需数据
- 避免频繁重新导航

### 等待策略
- 默认等待策略：`waitUntil: "done"`
- 动态内容：使用 `waitUntil: "networkidle"`
- 特定元素：使用 `mcp__lightpanda__waitForSelector`

## 与其他工具协同

### 与 market-research skill
```
场景：竞品分析
1. 使用 Lightpanda 批量抓取竞品网站
2. 提取结构化数据
3. 传递给 market-research skill 分析
```

### 与 claude-mem
```
场景：避免重复抓取
1. 查询 claude-mem 是否已有缓存
2. 如无缓存，使用 Lightpanda 抓取
3. 存储结果到 claude-mem
```

### 与 article-writing skill
```
场景：基于网页内容写文章
1. 使用 Lightpanda 提取参考资料
2. 传递给 article-writing skill 创作
```

## 实际使用示例

### 示例 1：抓取技术文档
```
用户："帮我抓取 https://docs.python.org/3/library/asyncio.html 的内容"

AI 应该：
1. 使用 mcp__lightpanda__goto 导航
2. 使用 mcp__lightpanda__markdown 提取内容
3. 返回 Markdown 格式的文档
```

### 示例 2：收集新闻链接
```
用户："收集 Hacker News 首页的所有文章链接"

AI 应该：
1. 使用 mcp__lightpanda__goto("https://news.ycombinator.com")
2. 使用 mcp__lightpanda__links 提取链接
3. 过滤出文章链接（排除导航链接）
```

### 示例 3：竞品网站分析
```
用户："分析这三个竞品网站的产品特点：[url1, url2, url3]"

AI 应该：
1. 对每个 URL 使用 Lightpanda 提取内容
2. 使用 mcp__lightpanda__structuredData 获取元数据
3. 汇总分析并生成对比报告
```

## 错误处理

### 常见错误
1. **导航失败** - 检查 URL 是否有效，增加超时时间
2. **内容为空** - 页面可能需要更长加载时间，使用 `waitUntil: "networkidle"`
3. **元素未找到** - 使用 `mcp__lightpanda__waitForSelector` 等待元素出现

### 降级策略
```
Lightpanda 失败 → 尝试 WebFetch → 尝试 curl → 告知用户限制
```

## 验证清单

在使用 Lightpanda 前，AI 应确认：
- [ ] 任务确实需要访问网页内容
- [ ] 没有更简单的替代方案（API、WebFetch）
- [ ] 用户提供了有效的 URL
- [ ] 了解可能的限制（Beta 阶段、API 覆盖不完整）
