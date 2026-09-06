#!/usr/bin/env bash
# 下载并裁剪自带字体到 assets/fonts/。
#
# 为什么自带字体：客户端要与 web 端「学术编辑风」一致（衬线标题 + Inter 正文数字），
# 且不允许运行期联网取字（离线可用、无第三方请求）。Noto Serif SC 完整可变字重约 25 MB，
# 用 pyftsubset 裁到「拉丁 + 标点 + CJK 基本区 + 全宽符号」，保留 wght 轴，产物入库。
#
# 用法：flutter/ 目录下执行 `tool/fetch_fonts.sh`。需要 curl、unzip、uvx（fonttools）。
set -euo pipefail

cd "$(dirname "$0")/.."
out="assets/fonts"
mkdir -p "$out"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

serif_url="https://github.com/notofonts/noto-cjk/raw/main/Serif/Variable/TTF/Subset/NotoSerifSC-VF.ttf"
inter_url="https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"

echo "==> 下载 Noto Serif SC 可变字体"
curl -fL --retry 3 -o "$work/NotoSerifSC-VF.ttf" "$serif_url"

echo "==> 裁剪 Noto Serif SC（拉丁/标点/CJK 基本区/全宽符号，保留 wght 轴）"
uvx --from fonttools pyftsubset "$work/NotoSerifSC-VF.ttf" \
  --unicodes="U+0000-00FF,U+2000-206F,U+3000-303F,U+4E00-9FFF,U+FF00-FFEF" \
  --layout-features='*' \
  --output-file="$out/NotoSerifSC-VF.ttf"

echo "==> 下载 Inter v4.1"
curl -fL --retry 3 -o "$work/Inter.zip" "$inter_url"
unzip -q -o "$work/Inter.zip" -d "$work/inter"
inter_ttf="$(find "$work/inter" -name 'InterVariable.ttf' -print -quit)"
if [[ -z "$inter_ttf" ]]; then
  inter_ttf="$(find "$work/inter" -name 'Inter-Variable.ttf' -print -quit)"
fi
if [[ -z "$inter_ttf" ]]; then
  inter_ttf="$(find "$work/inter" -name '*Variable*.ttf' -print -quit)"
fi
if [[ -z "$inter_ttf" ]]; then
  echo "未在 Inter 发布包中找到可变字体文件" >&2
  exit 1
fi
cp "$inter_ttf" "$out/InterVariable.ttf"

echo "==> 写入 OFL 许可"
{
  echo "本目录字体均以 SIL Open Font License 1.1 授权："
  echo
  echo "- NotoSerifSC-VF.ttf — Noto Serif SC，Copyright 2014-2021 Adobe (http://www.adobe.com/)，"
  echo "  取自 $serif_url，用 pyftsubset 裁剪字符集，保留 wght 轴。"
  echo "- InterVariable.ttf — Inter，Copyright 2016 The Inter Project Authors (https://github.com/rsms/inter)，"
  echo "  取自 $inter_url，未修改。"
  echo
  echo "许可全文：https://openfontlicense.org/open-font-license-official-text/"
} > "$out/OFL.txt"

ls -lh "$out"
