# Hermes Agent 飞牛NAS 安装包

一键安装 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 到飞牛OS。

## 🚀 快速安装

```bash
curl -fsSL https://raw.githubusercontent.com/iamkingab/hermes-fenniu/main/install.sh | sudo bash
```

或克隆仓库：

```bash
git clone https://github.com/iamkingab/hermes-fenniu.git
cd hermes-fenniu
sudo ./install.sh
```

## ✨ 特性

- ✅ **自动安装依赖** - Python、Git 等自动配置
- ✅ **虚拟环境隔离** - 不污染系统环境
- ✅ **系统服务集成** - 支持 systemctl 管理
- ✅ **飞牛OS适配** - 针对 NAS 环境优化

## 📋 系统要求

| 项目 | 要求 |
|------|------|
| 系统 | 飞牛OS / Linux |
| 架构 | x86_64 或 ARM64 |
| Python | >= 3.8 (自动安装) |
| 内存 | 512MB+ |
| 磁盘 | 500MB+ |

## 🔧 配置

安装后需要配置 API Key：

```bash
sudo nano /root/.hermes/.env
```

配置内容：

```env
# 必需
OPENAI_API_KEY=sk-your-key-here

# 可选
ANTHROPIC_API_KEY=
TELEGRAM_TOKEN=
DISCORD_TOKEN=
```

## 🚀 使用方法

### CLI 模式

```bash
# 启动交互式聊天
hermes chat

# 查看版本
hermes --version

# 查看帮助
hermes --help
```

### 网关服务

```bash
# 启动服务
sudo systemctl start hermes

# 开机自启
sudo systemctl enable hermes

# 查看状态
sudo systemctl status hermes

# 查看日志
sudo journalctl -u hermes -f
```

## 📍 安装位置

- 程序目录: `/opt/hermes`
- 配置目录: `/root/.hermes`
- 启动命令: `/usr/local/bin/hermes`
- 服务名: `hermes.service`

## 🗑️ 卸载

```bash
sudo systemctl stop hermes
sudo systemctl disable hermes
sudo rm /usr/local/bin/hermes
sudo rm -rf /opt/hermes
sudo rm -rf /root/.hermes
```

## 📖 更多信息

- [Hermes Agent 官方文档](https://hermes-agent.nousresearch.com/docs/)
- [GitHub 仓库](https://github.com/NousResearch/hermes-agent)
- [Discord 社区](https://discord.gg/NousResearch)

## 📄 许可证

MIT License - [Nous Research](https://nousresearch.com)
