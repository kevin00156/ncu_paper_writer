#!/usr/bin/env python3
"""跨平台中文字體偵測工具。

檢查系統中可用的中文字體，並推薦 NCU 論文 YAML 中 `CJKmainfont` 應填寫的值。

用法：
    python scripts/check-fonts.py
    python scripts/check-fonts.py --verbose
    python scripts/check-fonts.py --json    # 輸出 JSON 供腳本解析
"""

from __future__ import annotations

import argparse
import json
import platform
import subprocess
import sys
from pathlib import Path

# 候選字體（依優先序）
PREFERRED_FONTS_TC = [
    # NCU 嚴格規範
    "標楷體",
    "DFKai-SB",
    "BiauKai",
    # macOS 內建
    "LiSong Pro",
    "PMingLiU",
    "MingLiU",
    # 開源 fallback
    "Noto Serif CJK TC",
    "Noto Sans CJK TC",
    "Source Han Serif TC",
    "思源宋體",
    "Source Han Sans TC",
    "思源黑體",
]

# 中文字體名稱對應的字型檔關鍵字（用於 Windows 字體目錄掃描）
WINDOWS_FONT_HINTS = {
    "標楷體": ["kaiu.ttf", "DFKai-SB.ttf"],
    "細明體": ["mingliu.ttc", "PMingLiU.ttf"],
    "新細明體": ["mingliu.ttc"],
    "微軟正黑體": ["msjh.ttc", "msjh.ttf"],
}


def list_fonts_linux() -> list[str]:
    """使用 fc-list 列出系統可用字體。"""
    try:
        result = subprocess.run(
            ["fc-list", ":lang=zh-tw", "family"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            return []
        names = set()
        for line in result.stdout.splitlines():
            for name in line.split(","):
                names.add(name.strip())
        return sorted(names)
    except FileNotFoundError:
        return []


def list_fonts_macos() -> list[str]:
    """使用 system_profiler 列出 macOS 字體。"""
    try:
        result = subprocess.run(
            ["system_profiler", "SPFontsDataType"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            return []
        names = set()
        for line in result.stdout.splitlines():
            line = line.strip()
            if line.startswith("Family:"):
                names.add(line.split(":", 1)[1].strip())
        return sorted(names)
    except FileNotFoundError:
        return []


def list_fonts_windows() -> list[str]:
    """掃描 Windows Fonts 目錄並用 fontTools 讀取字體名稱。"""
    fonts_dir = Path(r"C:\Windows\Fonts")
    if not fonts_dir.exists():
        return []

    names = set()

    # 用檔名快速比對
    for chinese_name, hints in WINDOWS_FONT_HINTS.items():
        for hint in hints:
            if (fonts_dir / hint).exists():
                names.add(chinese_name)

    # 進階：用 fontTools 讀取
    try:
        from fontTools.ttLib import TTFont, TTLibError

        for font_path in fonts_dir.glob("*.tt[fc]"):
            try:
                font = TTFont(str(font_path), fontNumber=0)
                for record in font["name"].names:
                    if record.nameID in (1, 4, 16):
                        try:
                            name = record.toUnicode()
                            names.add(name)
                        except (UnicodeDecodeError, TTLibError):
                            continue
            except (TTLibError, Exception):
                continue
    except ImportError:
        pass

    return sorted(names)


def detect_fonts() -> list[str]:
    """根據 OS 偵測可用中文字體。"""
    system = platform.system()
    if system == "Linux":
        return list_fonts_linux()
    if system == "Darwin":
        return list_fonts_macos()
    if system == "Windows":
        return list_fonts_windows()
    return []


def find_recommended(available: list[str]) -> tuple[str | None, list[str]]:
    """從候選清單找出第一個可用字體，並回傳所有匹配的字體。"""
    matched = []
    for preferred in PREFERRED_FONTS_TC:
        for font in available:
            if preferred.lower() in font.lower() or font.lower() in preferred.lower():
                if preferred not in matched:
                    matched.append(preferred)
                break
    return (matched[0] if matched else None, matched)


def main() -> int:
    parser = argparse.ArgumentParser(description="檢查可用的中文字體並推薦 NCU 論文設定")
    parser.add_argument("--verbose", action="store_true", help="列出所有偵測到的字體")
    parser.add_argument("--json", action="store_true", help="輸出 JSON 格式")
    args = parser.parse_args()

    fonts = detect_fonts()
    recommended, matched = find_recommended(fonts)

    if args.json:
        output = {
            "platform": platform.system(),
            "available_count": len(fonts),
            "recommended": recommended,
            "matched": matched,
            "all_fonts": fonts if args.verbose else [],
        }
        print(json.dumps(output, ensure_ascii=False, indent=2))
        return 0

    print(f"=== NCU 論文字體檢查 ({platform.system()}) ===\n")

    if not fonts:
        print("⚠ 無法偵測到系統字體")
        print("\n提示：")
        if platform.system() == "Linux":
            print("  - 確認已安裝 fontconfig（apt install fontconfig）")
        elif platform.system() == "Windows":
            print("  - 確認 fontTools 已安裝（pip install fonttools）")
        return 1

    print(f"偵測到 {len(fonts)} 個中文字體\n")

    print("=== 推薦字體 ===")
    if matched:
        for i, font in enumerate(matched):
            marker = "★" if i == 0 else " "
            print(f"  {marker} {font}")
        print()
        print(f"建議在 paper.md YAML 中設定：")
        print(f'    CJKmainfont: "{recommended}"')
    else:
        print("  ✗ 未偵測到任何已知的中文論文字體")
        print()
        print("可用字體清單：")
        for font in fonts[:20]:
            print(f"  - {font}")
        if len(fonts) > 20:
            print(f"  ... 還有 {len(fonts) - 20} 個")

    if args.verbose:
        print("\n=== 全部偵測到的字體 ===")
        for font in fonts:
            print(f"  - {font}")

    return 0 if matched else 1


if __name__ == "__main__":
    sys.exit(main())
