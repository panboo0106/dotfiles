#!/bin/bash
# 多语言编码规范工具安装脚本
# 支持: macOS, Linux (Ubuntu/Debian)
# 基于 SFRD-PPQA-03-6.7 编码规范

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "  SANGFOR 多语言编码规范工具安装"
echo -e "========================================${NC}"
echo ""

# 检测操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    INSTALL_CMD="brew"
elif [ -f /etc/debian_version ]; then
    OS="ubuntu"
    INSTALL_CMD="apt-get"
else
    echo -e "${RED}❌ 不支持的操作系统${NC}"
    exit 1
fi

echo -e "${GREEN}检测到操作系统: $OS${NC}"
echo ""

# ============ 安装 Homebrew (macOS) ============
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo -e "${YELLOW}安装 Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}✓ Homebrew 已安装${NC}"
    fi
}

# ============ 安装 Node.js (JavaScript) ============
install_nodejs() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  安装 JavaScript 工具 (ESLint + Prettier)"
    echo -e "====================================${NC}"

    if command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Node.js 已安装${NC}"
        npm install -g eslint prettier
    else
        if [ "$OS" == "macos" ]; then
            brew install node
        else
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
        npm install -g eslint prettier
    fi

    echo -e "${GREEN}✓ ESLint 安装完成${NC}"
    echo -e "${GREEN}✓ Prettier 安装完成${NC}"
}

# ============ 安装 C++ 工具 ============
install_cpp_tools() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  安装 C++ 工具 (clang-tidy + clang-format)"
    echo -e "====================================${NC}"

    if [ "$OS" == "macos" ]; then
        brew install llvm
    else
        sudo apt-get update
        sudo apt-get install -y clang-tidy clang-format
    fi

    echo -e "${GREEN}✓ clang-tidy 安装完成${NC}"
    echo -e "${GREEN}✓ clang-format 安装完成${NC}"
}

# ============ 安装 Shell 工具 ============
install_shell_tools() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  安装 Shell 工具 (ShellCheck + shfmt)"
    echo -e "====================================${NC}"

    if [ "$OS" == "macos" ]; then
        brew install shellcheck shfmt
    else
        sudo apt-get update
        sudo apt-get install -y shellcheck

        # shfmt 需要从 GitHub 安装
        SHFMT_VERSION="v3.6.0"
        wget https://github.com/mvdan/sh/releases/download/$SHFMT_VERSION/shfmt_${SHFMT_VERSION}_linux_amd64 -O shfmt
        chmod +x shfmt
        sudo mv shfmt /usr/local/bin/
    fi

    echo -e "${GREEN}✓ ShellCheck 安装完成${NC}"
    echo -e "${GREEN}✓ shfmt 安装完成${NC}"
}

# ============ 安装 Python 工具 ============
install_python_tools() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  安装 Python 工具 (Ruff + Pylint)"
    echo -e "====================================${NC}"

    if command -v python3 >/dev/null 2>&1; then
        pip3 install --user ruff pylint
    elif command -v python >/dev/null 2>&1; then
        pip install --user ruff pylint
    else
        echo -e "${YELLOW}⚠️  Python 未安装，跳过${NC}"
        return
    fi

    echo -e "${GREEN}✓ Ruff 安装完成${NC}"
    echo -e "${GREEN}✓ Pylint 安装完成${NC}"
}

# ============ 安装 Go 工具 ============
install_go_tools() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  安装 Go 工具 (golangci-lint)"
    echo -e "====================================${NC}"

    if ! command -v go >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Go 未安装，跳过 golangci-lint${NC}"
        echo "请访问 https://golangci-lint.run/usage/install/ 手动安装"
        return
    fi

    # 安装 golangci-lint
    if ! command -v golangci-lint >/dev/null 2>&1; then
        if [ "$OS" == "macos" ]; then
            brew install golangci-lint
        else
            curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
        fi
    fi

    echo -e "${GREEN}✓ golangci-lint 安装完成${NC}"
}

# ============ 验证安装 ============
verify_installation() {
    echo ""
    echo -e "${BLUE}===================================="
    echo "  验证工具安装"
    echo -e "====================================${NC}"
    echo ""

    local tools_ok=true

    # JavaScript
    if command -v eslint >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ESLint"
    else
        echo -e "${RED}✗${NC} ESLint"
        tools_ok=false
    fi

    if command -v prettier >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Prettier"
    else
        echo -e "${RED}✗${NC} Prettier"
        tools_ok=false
    fi

    # C++
    if command -v clang-tidy >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} clang-tidy"
    else
        echo -e "${RED}✗${NC} clang-tidy"
        tools_ok=false
    fi

    if command -v clang-format >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} clang-format"
    else
        echo -e "${RED}✗${NC} clang-format"
        tools_ok=false
    fi

    # Shell
    if command -v shellcheck >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ShellCheck"
    else
        echo -e "${RED}✗${NC} ShellCheck"
        tools_ok=false
    fi

    if command -v shfmt >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} shfmt"
    else
        echo -e "${RED}✗${NC} shfmt"
        tools_ok=false
    fi

    # Python
    if command -v ruff >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Ruff"
    else
        echo -e "${RED}✗${NC} Ruff"
        tools_ok=false
    fi

    if command -v pylint >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Pylint"
    else
        echo -e "${RED}✗${NC} Pylint"
        tools_ok=false
    fi

    # Go
    if command -v golangci-lint >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} golangci-lint"
    else
        echo -e "${YELLOW}⚠️${NC} golangci-lint"
    fi

    echo ""
    if [ "$tools_ok" = true ]; then
        echo -e "${GREEN}✅ 所有工具安装完成！${NC}"
    else
        echo -e "${YELLOW}⚠️  部分工具未安装，请检查错误信息${NC}"
    fi
}

# ============ 主流程 ============
main() {
    if [ "$OS" == "macos" ]; then
        install_homebrew
    fi

    # 询问用户要安装哪些工具
    echo ""
    echo -e "${BLUE}请选择要安装的工具（输入 1-6，用空格分隔）:${NC}"
    echo "  1. JavaScript (ESLint + Prettier)"
    echo "  2. C++ (clang-tidy + clang-format)"
    echo "  3. Shell (ShellCheck + shfmt)"
    echo "  4. Python (Ruff + Pylint)"
    echo "  5. Go (golangci-lint)"
    echo "  6. 全部"
    echo ""
    read -p "请输入: " choices

    for choice in $choices; do
        case $choice in
            1)
                install_nodejs
                ;;
            2)
                install_cpp_tools
                ;;
            3)
                install_shell_tools
                ;;
            4)
                install_python_tools
                ;;
            5)
                install_go_tools
                ;;
            6)
                install_nodejs
                install_cpp_tools
                install_shell_tools
                install_python_tools
                install_go_tools
                ;;
            *)
                echo -e "${RED}无效选择: $choice${NC}"
                ;;
        esac
    done

    verify_installation

    echo ""
    echo -e "${GREEN}========================================"
    echo "  安装完成！"
    echo -e "========================================${NC}"
    echo ""
    echo "下一步："
    echo "  1. 复制 Makefile: cp ~/.config/nvim/Makefile.multilang ./Makefile"
    echo "  2. 配置 Git Hook: cp ~/.config/nvim/pre-commit.multilang .git/hooks/pre-commit"
    echo "  3. 运行检查: make all"
    echo ""
    echo "配置文件位置: ~/.config/nvim/"
    echo "使用文档: ~/.config/nvim/README.multilang.md"
    echo ""
}

# 运行主流程
main
