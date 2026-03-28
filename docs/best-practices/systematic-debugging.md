# Systematic Debugging 最佳实践

## 概述

系统化调试方法，通过结构化流程定位和修复问题，避免随机尝试。

## 四阶段调试流程

### 阶段 1：重现问题

**目标**：可靠地触发问题

**步骤**：
1. 记录触发条件
2. 创建最小复现用例
3. 确认每次都能重现

**示例**：
```bash
# 不好：问题偶尔出现
"有时候登录会失败"

# 好：明确的重现步骤
1. 清空浏览器缓存
2. 访问 /login
3. 输入用户名：test@example.com
4. 输入密码：wrong_password
5. 点击登录
→ 预期：显示错误提示
→ 实际：页面白屏
```

### 阶段 2：隔离问题

**目标**：缩小问题范围

**方法**：
- 二分法排查
- 注释代码块
- 添加日志输出
- 检查最近的代码变更

**示例**：
```javascript
// 添加日志定位问题
console.log('1. 开始登录');
const user = await findUser(email);
console.log('2. 找到用户:', user);
const valid = await validatePassword(password);
console.log('3. 密码验证:', valid);
// ... 继续添加日志
```

### 阶段 3：理解根因

**目标**：找到问题的真正原因

**问题清单**：
- 为什么会发生？
- 什么条件下发生？
- 什么时候开始的？
- 影响范围有多大？

**技巧**：
- 查看错误堆栈
- 检查相关代码变更历史
- 阅读相关文档
- 搜索类似问题

### 阶段 4：修复并验证

**目标**：修复问题并确保不再发生

**步骤**：
1. 编写失败的测试（RED）
2. 实现修复（GREEN）
3. 重构优化（REFACTOR）
4. 验证原问题已解决
5. 验证没有引入新问题

**示例**：
```javascript
// 1. 先写测试
test('login with wrong password shows error', async () => {
  const response = await login('test@example.com', 'wrong');
  expect(response.error).toBe('Invalid password');
  expect(response.status).toBe(401);
});

// 2. 运行测试 - 应该失败
// 3. 修复代码
// 4. 运行测试 - 应该通过
// 5. 运行所有测试 - 确保没有破坏其他功能
```

## 常见调试技术

### 1. 日志调试
```javascript
// 结构化日志
console.log('[AUTH]', { step: 'validate', user: email, valid });
```

### 2. 断点调试
- 使用 IDE 断点
- 使用 `debugger` 语句
- 检查变量状态

### 3. 二分法排查
```bash
# Git bisect 找到引入 bug 的提交
git bisect start
git bisect bad          # 当前版本有问题
git bisect good v1.0.0  # v1.0.0 没问题
# Git 自动二分查找
```

### 4. 对比法
- 对比正常和异常的输入
- 对比不同环境的行为
- 对比代码变更前后

## 调试反模式（避免）

❌ **随机尝试**
```javascript
// 不好：没有理解就随机修改
- password = password.trim()  // 试试去空格？
+ password = password.toLowerCase()  // 试试小写？
```

✅ **系统化分析**
```javascript
// 好：理解问题后针对性修复
// 问题：密码验证失败因为大小写敏感
// 根因：数据库存储的是小写，但验证时没有转换
+ password = password.toLowerCase()  // 统一转小写
```

❌ **过早优化**
- 先让代码工作
- 再考虑性能优化

❌ **忽略测试**
- 修复后必须验证
- 添加回归测试

## 与 OMC 集成

### 增强现有 Debugger

可以将这些方法集成到 OMC debugger agent：

```markdown
# ~/.claude/agents/debugger.md

增加系统化调试流程：
1. 重现问题
2. 隔离问题
3. 理解根因
4. 修复并验证
```

### 使用场景

- 遇到难以定位的 bug
- 需要系统化排查问题
- 需要记录调试过程

## 参考资料

- 来源：借鉴 Superpowers 的 systematic-debugging skill
- 延伸阅读：《调试九法》

---

**状态**：最佳实践文档
**集成方式**：增强 OMC debugger，不依赖 Superpowers
