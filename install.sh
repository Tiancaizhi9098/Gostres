#!/bin/bash

# 检查是否需要 root 权限（根据 bot.go 需求决定是否保留）
if [ "$(id -u)" != "0" ]; then
   echo "This script may require root permissions. Try sudo $0"
   exit 1
fi

# 检测操作系统和架构
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
echo "Detected OS: $OS, Architecture: $ARCH"

# 定义仓库的 raw 文件基础 URL（替换为你的实际仓库）
REPO_URL="https://raw.githubusercontent.com/Tiancaizhi9098/Gostres/main"

# 根据操作系统和架构选择对应的程序文件
case "$OS:$ARCH" in
  "linux:i386"|"linux:x86")
    PROGRAM_NAME="x86"
    ;;
  "linux:x86_64"|"linux:amd64")
    PROGRAM_NAME="x86_64"
    ;;
  "linux:arm"|"linux:armv5l")
    PROGRAM_NAME="armv5l"
    ;;
  "linux:armv6l")
    PROGRAM_NAME="armv6l"
    ;;
  "linux:armv7l")
    PROGRAM_NAME="armv7l"
    ;;
  "linux:arm64"|"linux:aarch64")
    PROGRAM_NAME="armv8l"
    ;;
  "linux:mips")
    PROGRAM_NAME="mips"
    ;;
  "linux:mipsel")
    PROGRAM_NAME="mipsel"
    ;;
  "linux:mips64")
    PROGRAM_NAME="mips64"
    ;;
  "linux:mips64el")
    PROGRAM_NAME="mips64le"
    ;;
  "linux:ppc64")
    PROGRAM_NAME="ppc64"
    ;;
  "linux:ppc64le")
    PROGRAM_NAME="ppc64le"
    ;;
  "linux:riscv64")
    PROGRAM_NAME="riscv64"
    ;;
  "linux:s390x")
    PROGRAM_NAME="s390x"
    ;;
  "cygwin_nt-*:i386"|"mingw*:i386"|"cygwin_nt-*:x86"|"mingw*:x86")
    PROGRAM_NAME="x86.exe"
    ;;
  "cygwin_nt-*:x86_64"|"mingw*:x86_64"|"cygwin_nt-*:amd64"|"mingw*:amd64")
    PROGRAM_NAME="x86_64.exe"
    ;;
  "cygwin_nt-*:arm64"|"mingw*:arm64"|"cygwin_nt-*:aarch64"|"mingw*:aarch64")
    PROGRAM_NAME="armv8l.exe"
    ;;
  *)
    echo "错误：不支持的操作系统和架构组合 '$OS:$ARCH'"
    exit 1
    ;;
esac

# 构造下载 URL
PROGRAM_URL="${REPO_URL}/${PROGRAM_NAME}"

# 下载程序
echo "Downloading $PROGRAM_NAME from $PROGRAM_URL..."
curl -L -o "$PROGRAM_NAME" "$PROGRAM_URL" || {
    echo "错误：无法下载 $PROGRAM_NAME"
    exit 1
}

# 验证文件是否下载成功
if [ ! -f "$PROGRAM_NAME" ]; then
    echo "错误：$PROGRAM_NAME 未下载成功"
    exit 1
fi

# 检查文件是否为可执行文件（Linux 下）
if [ "$OS" = "linux" ] && ! file "$PROGRAM_NAME" | grep -q "executable"; then
    echo "错误：$PROGRAM_NAME 不是有效的可执行文件"
    exit 1
fi

# 赋予执行权限（仅对 Linux 二进制文件）
if [ "$OS" = "linux" ]; then
    chmod +x "$PROGRAM_NAME"
    echo "已为 $PROGRAM_NAME 赋予执行权限"
fi

# 执行程序
echo "运行 $PROGRAM_NAME..."
if [ "$OS" = "linux" ]; then
    ./"$PROGRAM_NAME" || {
        echo "错误：无法执行 $PROGRAM_NAME"
        exit 1
    }
elif [[ "$OS" == "cygwin"* || "$OS" == "mingw"* ]]; then
    # Windows 环境下直接运行 .exe 文件（假设在 WSL 或 Git Bash 中）
    ./"$PROGRAM_NAME" || {
        echo "错误：无法执行 $PROGRAM_NAME（可能需要 wine 或原生 Windows 环境）"
        exit 1
    }
else
    echo "错误：不支持的操作系统 '$OS'"
    exit 1
fi

# 可选：清理下载的文件
# rm "$PROGRAM_NAME"
# echo "已清理 $PROGRAM_NAME"

echo "执行成功完成！"
