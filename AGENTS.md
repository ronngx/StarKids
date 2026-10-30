# 仓库指南（Repository Guidelines）

## 项目结构与模块组织

StarKids 是一个使用 Next.js 15 App Router、React、TypeScript、Prisma 和 SQLite 的应用。

- `src/app/`：页面路由、布局、API 处理器，以及 `(admin)` 和 `(kids)` 路由组。
- `src/components/`：可复用的 UI、导航、认证和通知组件。
- `src/lib/`：Server Actions、数据库访问、业务引擎、校验和推送集成。
- `prisma/schema.prisma`：数据模型；`prisma/migrations/`：生产迁移；`prisma/seed.ts`：种子数据。
- `tests/`：Node 测试运行器和 Prisma 集成测试。
- `public/`：静态资源；`scripts/`：部署和数据迁移脚本。

服务端逻辑应放在 `src/lib/` 或路由处理器中。当前部署目标是使用 SQLite 的可信局域网环境。

## 构建、测试与开发命令

```bash
npm install                    # 安装依赖
npm run dev                    # 启动本地开发服务器
npm run db:generate            # 生成 Prisma Client
npm run db:push                # 本地初始化时直接同步 Schema
npx prisma migrate deploy     # 应用已提交的生产迁移
npm run build                  # 创建生产构建
npm run start                  # 启动生产构建
npm run lint                   # 运行 ESLint
npx tsx --test tests/*.test.ts # 运行全部测试
npm run deploy:production     # 备份、迁移、构建并重启生产服务
```

使用外部进程管理器时，执行 `npm run deploy:production -- --no-start`。生产环境应使用已提交的迁移。

## 代码风格与命名约定

使用严格模式 TypeScript、两个空格缩进、省略分号和双引号。React 组件与类型使用 `PascalCase`，函数和变量使用 `camelCase`，路由目录使用小写。优先使用现有路径别名，例如 `@/lib/db`。新增代码应避免 `any`、未使用变量和不必要的 `console` 输出。

## 测试指南

测试使用 Node 内置的 `node:test` 运行器和 `assert/strict`，部分测试使用临时 SQLite 数据库隔离运行。测试文件使用 `*.test.ts` 命名，并覆盖成功路径以及权限和错误路径。提交前运行完整测试套件。

## 提交与 Pull Request 指南

近期提交使用简短的中文祈使句，例如 `修复宠物枚举数据库迁移`。提交信息应保持简洁，可注明受影响的功能区域。每个提交应聚焦单一变更；修改 Schema 时必须同时提交对应迁移。

Pull Request 应说明用户可见的行为变化、数据库或配置变化和验证命令；明显的 UI 变更应附截图，同时注明迁移步骤和局域网部署假设。

## 安全与配置提示

不要提交 `.env.local`、SQLite 数据库、Server酱³ SendKey 或 `.next` 构建产物。Server酱³ SendKey 应通过家庭管理页面录入，并使用应用内置的局域网密钥保存。除非完善认证和密钥管理方案，否则请保持应用只在可信局域网内运行。
