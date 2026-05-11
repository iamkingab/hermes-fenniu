#!/bin/bash
set -e

# Hermes Agent 飞牛NAS 一键安装脚本
VERSION="0.9.0"
INSTALL_DIR="/opt/hermes"
CONFIG_DIR="$HOME/.hermes"
BIN_DIR="/usr/local/bin"

echo "=========================================="
echo "  Hermes Agent 飞牛NAS 安装脚本 v${VERSION}"
echo "=========================================="
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用 sudo 运行"
    echo "   sudo ./install.sh"
    exit 1
fi

# 检测架构
echo "📋 检测系统架构..."
ARCH=$(uname -m)
case $ARCH in
    x86_64|amd64)
        echo "   ✓ x86_64 (Intel/AMD)"
        ;;
    aarch64|arm64)
        echo "   ✓ ARM64"
        ;;
    *)
        echo "   ⚠️  架构: $ARCH (可能不完全兼容)"
        ;;
esac

# 检查 Python
echo ""
echo "📋 检查 Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VER=$(python3 --version)
    echo "   ✓ $PYTHON_VER"
else
    echo "   ⚠️  未安装，正在安装..."
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq python3 python3-pip python3-venv
    elif command -v yum &> /dev/null; then
        yum install -y -q python3 python3-pip
    elif command -v dnf &> /dev/null; then
        dnf install -y -q python3 python3-pip
    fi
    echo "   ✓ Python 安装完成"
fi

# 安装依赖
echo ""
echo "📦 安装系统依赖..."
if command -v apt-get &> /dev/null; then
    apt-get install -y -qq curl wget git build-essential libffi-dev
elif command -v yum &> /dev/null; then
    yum install -y -q curl wget git gcc make libffi-devel
elif command -v dnf &> /dev/null; then
    dnf install -y -q curl wget git gcc make libffi-devel
fi

# 创建安装目录
echo ""
echo "📁 创建安装目录..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# 克隆项目
echo ""
echo "📥 下载 Hermes Agent..."
cd "$INSTALL_DIR"
if [ -d ".git" ]; then
    echo "   检测到已有安装，更新中..."
    git pull
else
    git clone https://github.com/NousResearch/hermes-agent.git .
fi

# 创建虚拟环境
echo ""
echo "🐍 配置 Python 环境..."
python3 -m venv venv
source venv/bin/activate

# 安装 Python 依赖
echo ""
echo "📦 安装 Python 依赖..."
pip install --upgrade pip
pip install -e .

# 创建配置文件
echo ""
echo "⚙️  创建配置文件..."
if [ ! -f "$CONFIG_DIR/.env" ]; then
    cat > "$CONFIG_DIR/.env" << 'ENVFILE'
# Hermes Agent 配置文件
# 请填入你的 API Key

# OpenAI (必需)
OPENAI_API_KEY=your_openai_api_key_here

# 可选: 其他提供商
# ANTHROPIC_API_KEY=
# OPENROUTER_API_KEY=

# 模型配置
DEFAULT_MODEL=gpt-4

# 网关配置 (可选)
# TELEGRAM_TOKEN=
# DISCORD_TOKEN=
ENVFILE
    echo "   ✓ 配置文件已创建: $CONFIG_DIR/.env"
    echo "   ⚠️  请编辑配置文件填入你的 API Key"
else
    echo "   ✓ 配置文件已存在"
fi

# 创建启动脚本
echo ""
echo "🚀 创建启动脚本..."
cat > "$BIN_DIR/hermes" << 'STARTSCRIPT'
#!/bin/bash
source /opt/hermes/venv/bin/activate
cd /opt/hermes
python -m hermes_cli.main "$@"
STARTSCRIPT
chmod +x "$BIN_DIR/hermes"

# 创建 systemd 服务
echo ""
echo "📋 创建系统服务..."
cat > /etc/systemd/system/hermes.service << 'SERVICEFILE'
[Unit]
Description=Hermes Agent Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/hermes
Environment="PATH=/opt/hermes/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/opt/hermes/venv/bin/python -m gateway.run
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEFILE

systemctl daemon-reload

# 验证安装
echo ""
echo "✅ 安装完成！"
echo ""
echo "📍 安装信息:"
echo "   位置: $INSTALL_DIR"
echo "   配置: $CONFIG_DIR/.env"
echo "   命令: hermes"
echo ""
echo "🚀 使用方法:"
echo "   1. 编辑配置文件:"
echo "      sudo nano $CONFIG_DIR/.env"
echo ""
echo "   2. 启动 CLI:"
echo "      hermes chat"
echo ""
echo "   3. 启动网关服务:"
echo "      sudo systemctl start hermes"
echo "      sudo systemctl enable hermes"
echo ""
echo "   4. 查看状态:"
echo "      hermes --version"
echo "      sudo systemctl status hermes"
echo ""
echo "=========================================="
