# 🌟 StarKids — 小朋友奖励乐园

> 🎮 用游戏化的方式，让好习惯自然生长  
> 🎮 Gamify good habits — let them grow naturally

[![Next.js](https://img.shields.io/badge/Next.js-15.4-black?logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19-blue?logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Prisma](https://img.shields.io/badge/Prisma-7.8-2D3748?logo=prisma)](https://www.prisma.io/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.2-38B2AC?logo=tailwind-css)](https://tailwindcss.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)

---

## 📖 目录 / Table of Contents

- [项目简介 / Overview](#-项目简介--overview)
- [核心功能 / Core Features](#-核心功能--core-features)
- [技术栈 / Tech Stack](#-技术栈--tech-stack)
- [项目结构 / Project Structure](#-项目结构--project-structure)
- [快速开始 / Quick Start](#-快速开始--quick-start)
- [Docker 部署 / Docker Deployment](#-docker-部署--docker-deployment)
- [数据库 / Database](#-数据库--database)
- [API 接口 / API Endpoints](#-api-接口--api-endpoints)
- [环境变量 / Environment Variables](#-环境变量--environment-variables)

---

## 🎯 项目简介 / Overview

**StarKids** 是一个面向家庭的游戏化奖励系统，帮助家长通过积分激励孩子养成好习惯。孩子完成任务获得积分，积分可以兑换奖励，同时还能喂养虚拟宠物、解锁成就徽章。

**StarKids** is a family-oriented gamified reward system that helps parents motivate children to build good habits through a points-based incentive model. Kids earn points by completing tasks, redeem rewards, feed virtual pets, and unlock achievement badges.

### 👨‍👩‍👧‍👦 双角色系统 / Dual-Role System

| 角色 Role | 界面 Interface | 功能 Functions |
|-----------|---------------|----------------|
| 👨‍👩‍👧 **家长 Parent** | 管理后台 Admin Dashboard | 创建任务、审核完成、管理奖励、查看分析、家庭管理 |
| 🧒 **小朋友 Kid** | 儿童界面 Kids Interface | 查看任务、提交完成、兑换奖励、喂养宠物、收集成就 |

---

## ✨ 核心功能 / Core Features

### 📋 任务系统 / Task System
- **多种任务类型**：日常任务、一次性任务、挑战任务、习惯养成
- **任务分类**：家务、习惯、学习、运动、社交、创意等
- **灵活配置**：积分值、自动审批、任务频率、难度等级
- **批量分配**：支持将任务分配给多个家庭成员

### 🪙 积分系统 / Points System
- **积分规则**：周末双倍积分、生日三倍积分、每日积分上限
- **积分重置**：支持不重置 / 每月 / 每学期 / 每年重置
- **实时余额**：小朋友和家长都能实时查看积分变动
- **积分历史**：完整的积分获取与消费记录

### 🐾 宠物系统 / Pet System
- **8 种宠物**：🐱 猫、🐶 狗、🦊 狐狸、🐰 兔子、🐲 龙、🦄 独角兽、🐼 熊猫、🐧 企鹅
- **5 个进化阶段**：蛋宝宝 → 破壳啦 → 成长中 → 进化了 → 完全体
- **心情系统**：喂食提升心情，积分驱动进化
- **装扮系统**：多种装扮可供选择

### 🛒 积分商城 / Reward Shop
- **奖励分类**：玩具、零食、特权、体验、零花钱、数字奖励
- **库存管理**：限量奖励、每人限购、冷却时间
- **审批流程**：小朋友兑换 → 家长审批/拒绝
- **精选推荐**：支持设置精选奖励

### 🏆 成就系统 / Achievement System
- **多类别成就**：劳动、习惯、学习、运动、社交、特殊
- **隐藏成就**：支持隐藏成就，增加惊喜感
- **积分奖励**：解锁成就获得额外积分

### 📊 数据分析 / Analytics
- **概览面板**：总完成任务数、总积分、审批率、待处理数
- **成员统计**：每位成员的积分、宠物、完成情况
- **积分趋势**：可视化积分变化趋势
- **分类分布**：任务分类饼图

### 👨‍👩‍👧‍👦 家庭管理 / Family Management
- **邀请码机制**：通过邀请码加入家庭
- **成员管理**：添加小朋友；家长可在成员条目下方编辑自己及同一家庭成员的昵称、登录用户名，并按需重设密码（新密码留空则保留原密码）
- **角色区分**：家长与小朋友不同权限

### 🔔 通知系统 / Notifications
- **实时通知**：任务审批、奖励兑换状态变更通知
- **已读管理**：支持标记已读

---

## 🛠 技术栈 / Tech Stack

| 类别 Category | 技术 Technology | 说明 Description |
|--------------|----------------|------------------|
| **框架 Framework** | Next.js 15.4 | App Router, Server Actions |
| **UI 库 UI Library** | React 19 | 函数组件 + Hooks |
| **语言 Language** | TypeScript 5.8 | 严格类型检查 |
| **样式 Styling** | Tailwind CSS 4.2 | 原子化 CSS |
| **ORM** | Prisma 7.8 | 类型安全数据库操作 |
| **认证 Auth** | NextAuth.js v5 | JWT 策略 |
| **动画 Animation** | Framer Motion | 页面过渡动画 |
| **图表 Charts** | Recharts | 数据可视化 |
| **表单 Form** | React Hook Form + Zod | 表单验证 |
| **UI 组件 UI Components** | Radix UI | 无障碍原语组件 |
| **图标 Icons** | Lucide React | 矢量图标库 |
| **密码加密 Password** | bcryptjs | 密码哈希 |

---

## 📁 项目结构 / Project Structure

```
kids-flow/
├── prisma/                     # 数据库 Schema 与迁移
│   ├── schema.prisma           # 数据模型定义
│   ├── seed.ts                 # 种子数据
│   └── migrations/             # 迁移文件
├── src/
│   ├── app/
│   │   ├── (admin)/admin/      # 家长管理后台 (路由组)
│   │   │   ├── page.tsx        # 仪表盘首页
│   │   │   ├── tasks/          # 任务管理
│   │   │   ├── shop/           # 奖励管理
│   │   │   ├── family/         # 家庭管理
│   │   │   ├── analytics/      # 数据分析
│   │   │   ├── achievements/   # 成就管理
│   │   │   ├── pets/           # 宠物管理
│   │   │   ├── points/         # 积分配置
│   │   │   └── notifications/  # 通知管理
│   │   ├── (kids)/kids/        # 小朋友界面 (路由组)
│   │   │   ├── page.tsx        # 首页
│   │   │   ├── tasks/          # 我的任务
│   │   │   ├── shop/           # 积分商城
│   │   │   ├── pet/            # 我的宠物
│   │   │   ├── achievements/   # 我的成就
│   │   │   └── notifications/  # 我的通知
│   │   ├── api/                # API 路由
│   │   │   ├── admin/          # 管理端 API
│   │   │   ├── kids/           # 儿童端 API
│   │   │   ├── tasks/          # 任务 API
│   │   │   ├── shop/           # 商城 API
│   │   │   ├── family/         # 家庭 API
│   │   │   ├── points/         # 积分 API
│   │   │   ├── notifications/  # 通知 API
│   │   │   ├── auth/           # 认证 API
│   │   │   └── register/       # 注册 API
│   │   ├── login/              # 登录页
│   │   ├── register/           # 注册页
│   │   └── layout.tsx          # 根布局
│   ├── components/ui/          # 通用 UI 组件
│   ├── lib/
│   │   ├── actions/            # Server Actions
│   │   │   ├── tasks.ts        # 任务业务逻辑
│   │   │   ├── shop.ts         # 商城业务逻辑
│   │   │   ├── pets.ts         # 宠物业务逻辑
│   │   │   ├── achievements.ts # 成就业务逻辑
│   │   │   ├── family.ts       # 家庭业务逻辑
│   │   │   ├── notifications.ts# 通知业务逻辑
│   │   │   ├── outfits.ts      # 装扮业务逻辑
│   │   │   └── register.ts     # 注册业务逻辑
│   │   ├── constants.ts        # 共享常量
│   │   ├── db.ts               # 数据库客户端
│   │   └── utils.ts            # 工具函数
│   ├── auth.ts                 # NextAuth 配置
│   └── middleware.ts           # 路由中间件
├── docker/                     # Docker 配置
├── Dockerfile                  # 多阶段构建
├── docker-compose.yml          # 服务编排
└── package.json
```

---

## 🚀 快速开始 / Quick Start

### 前置要求 / Prerequisites

- **Node.js** >= 22
- **npm** >= 10

### 本地开发 / Local Development

```bash
# 1. 克隆项目 / Clone the project
git clone <repo-url>
cd kids-flow

# 2. 安装依赖 / Install dependencies
npm install

# 3. 生成 Prisma 客户端 / Generate Prisma client
npm run db:generate

# 4. 初始化数据库 / Initialize database
npm run db:push

# 5. (可选) 填充种子数据 / (Optional) Seed the database
npm run db:seed

# 6. 启动开发服务器 / Start dev server
npm run dev
```

打开浏览器访问 [http://localhost:3000](http://localhost:3000)  
Open your browser at [http://localhost:3000](http://localhost:3000)

### 可用脚本 / Available Scripts

| 命令 Command | 说明 Description |
|-------------|------------------|
| `npm run dev` | 启动开发服务器 / Start dev server |
| `npm run build` | 构建生产版本 / Build for production |
| `npm run start` | 启动生产服务器 / Start production server |
| `npm run lint` | 代码检查 / Lint code |
| `npm run db:generate` | 生成 Prisma 客户端 / Generate Prisma client |
| `npm run db:push` | 推送 Schema 到数据库 / Push schema to DB |
| `npm run db:seed` | 填充种子数据 / Seed the database |
| `npm run db:studio` | 打开 Prisma Studio / Open Prisma Studio |

---

## 🐳 Docker 部署 / Docker Deployment

### 一键部署 / One-Click Deploy

```bash
# 本地构建应用镜像并启动所有服务 / Build the app image locally and start all services
docker compose up -d --build

# 或使用部署脚本 / Or use the deployment script
bash docker-deploy.sh

# 查看日志 / View logs
docker compose logs -f

# 停止服务 / Stop services
docker compose down
```

### 服务架构 / Service Architecture

| 服务 Service | 镜像 Image | 端口 Port | 说明 Description |
|-------------|-----------|-----------|------------------|
| `app` | 本地构建 `starkids-app:local` | `3000` | Next.js 应用 |
| `db` | `postgres:17-alpine` | `5432` | PostgreSQL 数据库 |

### Dockerfile 特性 / Dockerfile Features

- **多阶段构建**：分离依赖安装、构建、运行阶段，最小化镜像体积
- **PostgreSQL 适配**：构建时自动切换数据库 Provider
- **健康检查**：数据库就绪后才启动应用
- **非 root 用户**：以 `nextjs` 用户运行，提升安全性
- **增量构建缓存**：使用 BuildKit 持久保存 npm 下载缓存和 Next.js 编译缓存，源码更新后可继续复用
- **本地字体**：随项目托管 Noto Sans SC 和 ZCOOL KuaiLe，构建无需下载 Google 字体；保留按字形范围加载和原字体许可
- **独立 Prisma 缓存层**：只在 Prisma 文件或依赖变化时重新生成 Client，普通页面修改会跳过该步骤
- **复用依赖安装**：生产依赖从完整依赖中裁剪，避免重复安装并编译原生模块
- **运行时认证配置**：`AUTH_SECRET` 和数据库连接只在运行时注入实际值，修改这些配置不会触发应用重新编译

构建需要支持 BuildKit 的 Docker / Docker Compose V2。更新 Dockerfile 后首次构建会重新准备依赖和缓存，后续页面修改才会受益；Next.js 仍会执行生产构建、类型检查和页面生成。

```bash
# 显示每个构建步骤，便于确认缓存命中和耗时
docker compose --progress=plain build app

# 使用已构建的镜像启动服务
docker compose up -d --no-build
```

缓存保存在当前 Docker builder 中，换机器或清理 builder 缓存后需要重新建立。日常更新请保留构建缓存，避免使用 `--no-cache` 或执行 `docker builder prune`。字体资源和许可位于 `public/fonts`，更新字体时需同步更新 `src/app/fonts.css` 中的引用。

---

## 🗄 数据库 / Database

### 开发环境 / Development

使用 **SQLite**（零配置，开箱即用）  
Using **SQLite** (zero-config, works out of the box)

```
DATABASE_URL="file:./dev.db"
```

### 生产环境 / Production (Docker)

使用 **PostgreSQL 17**  
Using **PostgreSQL 17**

```
DATABASE_URL="postgresql://starkids:starkids@db:5432/starkids"
```

### 核心数据模型 / Core Data Models

| 模型 Model | 说明 Description |
|-----------|------------------|
| `User` | 用户账户 / User account |
| `Family` | 家庭 / Family group |
| `FamilyMember` | 家庭成员 / Family member |
| `Task` | 任务定义 / Task definition |
| `TaskCompletion` | 任务完成记录 / Task completion record |
| `Reward` | 奖励定义 / Reward definition |
| `RewardRedemption` | 奖励兑换记录 / Reward redemption record |
| `Pet` | 虚拟宠物 / Virtual pet |
| `PetOutfit` | 宠物装扮 / Pet outfit |
| `Achievement` | 成就定义 / Achievement definition |
| `MemberAchievement` | 成员成就解锁 / Member achievement unlock |
| `Notification` | 通知 / Notification |
| `PointConfig` | 积分配置 / Points configuration |

---

## 🔌 API 接口 / API Endpoints

### 认证 / Authentication

账号使用 **用户名 + 密码**，注册和家长添加小朋友均不需要邮箱或邮件服务。用户名支持中文、字母、数字、下划线、短横线和点，长度为 2–64 个字符；首尾空格会移除，英文字母统一为小写。用户名在整个系统内唯一，昵称可重复。密码至少 6 位。

从旧版升级时，Docker 启动会自动应用数据库迁移：原邮箱 `@` 前的名称会转换为用户名，例如 `Dad@example.com` 转为 `dad`。如果该名称重名、不符合规则或以 `legacy_` 开头，会转换为 `legacy_用户ID`。用户 ID、原密码、家庭、任务和积分均保留。家长可以在“家庭成员”页面查看各成员的登录用户名。需要核对迁移后的账号时可执行：

```bash
docker compose exec db psql -U starkids -d starkids -c 'SELECT username, name FROM users ORDER BY "createdAt";'
```

本地 SQLite 已有旧账号时，先运行下面的迁移命令，再运行 `npm run db:push`。新安装直接运行 `npm run db:push`。

```bash
npm run db:migrate-usernames:sqlite
# 数据库不在默认 dev.db 时，指定文件路径
npm run db:migrate-usernames:sqlite -- /path/to/dev.db
```

| 方法 Method | 路径 Path | 说明 Description |
|------------|----------|------------------|
| `POST` | `/api/register` | 用户注册 / User registration |
| `POST` | `/api/auth/*` | NextAuth 认证 / NextAuth authentication |

### 管理端 / Admin

| 方法 Method | 路径 Path | 说明 Description |
|------------|----------|------------------|
| `GET` | `/api/admin/analytics` | 获取分析数据 / Get analytics |
| `GET` | `/api/admin/achievements` | 获取成就列表 / Get achievements |
| `GET` | `/api/admin/outfits` | 获取装扮列表 / Get outfits |
| `GET` | `/api/tasks` | 获取任务列表 / Get tasks |
| `POST` | `/api/tasks` | 创建任务 / Create task |
| `POST` | `/api/tasks/[taskId]/assign` | 分配任务 / Assign task |
| `GET` | `/api/shop` | 获取商城数据 / Get shop data |
| `GET` | `/api/points/config` | 获取积分配置 / Get points config |
| `POST` | `/api/points/config` | 更新积分配置 / Update points config |
| `GET` | `/api/family/members` | 获取家庭成员 / Get family members |
| `PATCH` | `/api/family/members` | 家长修改同一家庭成员的昵称、用户名及可选新密码（FormData：`memberId`、`nickname`、`username`、`password`） |
| `POST` | `/api/family/add-kid` | 添加小朋友 / Add kid |
| `GET` | `/api/notifications` | 获取通知 / Get notifications |

### 儿童端 / Kids

| 方法 Method | 路径 Path | 说明 Description |
|------------|----------|------------------|
| `GET` | `/api/kids/me` | 获取个人信息 / Get my info |
| `GET` | `/api/kids/tasks` | 获取我的任务 / Get my tasks |
| `GET` | `/api/kids/shop` | 获取积分商城 / Get shop |
| `GET` | `/api/kids/pet` | 获取我的宠物 / Get my pet |
| `GET` | `/api/kids/achievements` | 获取我的成就 / Get my achievements |

---

## 🔐 环境变量 / Environment Variables

| 变量 Variable | 说明 Description | 默认值 Default |
|--------------|------------------|----------------|
| `DATABASE_URL` | 数据库连接 / Database URL | `file:./dev.db` |
| `AUTH_SECRET` | 认证密钥 / Auth secret | (必填 Required) |
| `AUTH_URL` | 认证 URL / Auth URL | `http://localhost:3000` |
| `NEXT_PUBLIC_APP_URL` | 应用 URL / App URL | `http://localhost:3000` |

---

## 📄 许可证 / License

MIT

---

<p align="center">
  <b>🌟 StarKids — 让好习惯自然生长 🌟</b><br/>
  <sub>Built with ❤️ using Next.js + Prisma + Tailwind CSS</sub>
</p>
