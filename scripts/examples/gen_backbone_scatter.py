"""gen_backbone_scatter.py — 範例：產生論文中模型比較散點圖。

此檔案展示如何用 Python + matplotlib 生成符合 NCU 論文風格的圖表：
  - 中文字體自動偵測
  - 多族群（CNN / Transformer / 混合）配色
  - Pareto 前緣分析
  - 標籤自動避讓（adjustText）

依賴：matplotlib, pandas, numpy, adjustText

用法（請依照自己的研究調整資料來源與分類）：
  1. 將 CSV 路徑 (`CSV`) 改為你的實驗結果檔
  2. 修改 FAMILY_MAP 對應你的模型分類
  3. 執行：python scripts/examples/gen_backbone_scatter.py

範例 CSV 欄位需求：
  run, parameters, accuracy, training_time
"""

import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib.gridspec import GridSpec
from adjustText import adjust_text

# ── 字型 ─────────────────────────────────────────────────────────────────
_registered = {f.name for f in fm.fontManager.ttflist}
for _name in ["Noto Sans CJK TC", "Noto Serif CJK TC",
              "Noto Sans CJK JP", "Noto Serif CJK JP",
              "AR PL UKai TW", "DFKai-SB"]:
    if _name in _registered:
        matplotlib.rcParams["font.family"] = _name
        break
else:
    for _f in fm.fontManager.ttflist:
        if "NotoSansCJK" in _f.fname or "NotoSerifCJK" in _f.fname:
            matplotlib.rcParams["font.family"] = _f.name
            break
matplotlib.rcParams["axes.unicode_minus"] = False

# ── 資料 ─────────────────────────────────────────────────────────────────
# 請改為你的實驗結果 CSV 路徑
CSV = "outputs/metrics/results_summary.csv"
df = pd.read_csv(CSV)

# ── 族群對應表 ────────────────────────────────────────────────────────────
FAMILY_MAP = {
    # CNN 家族
    "resnet50":                    "CNN 家族",
    "resnet101":                   "CNN 家族",
    "resnet152":                   "CNN 家族",
    "regnetx_032":                 "CNN 家族",
    "regnety_032":                 "CNN 家族",
    "convnext_tiny":               "CNN 家族",
    "convnext_base":               "CNN 家族",
    "convnextv2_nano":             "CNN 家族",
    "convnextv2_tiny":             "CNN 家族",
    "convnextv2_base":             "CNN 家族",
    "tf_efficientnetv2_s":         "CNN 家族",
    "tf_efficientnetv2_m":         "CNN 家族",
    # Transformer 家族
    "vit_small_patch16_224":       "Transformer 家族",
    "vit_base_patch16_224":        "Transformer 家族",
    "deit3_small_patch16_224":     "Transformer 家族",
    "deit3_base_patch16_224":      "Transformer 家族",
    "eva02_small_patch14_224":     "Transformer 家族",
    "eva02_base_patch14_224":      "Transformer 家族",
    "beitv2_base_patch16_224":     "Transformer 家族",
    "vit_base_patch16_siglip_224": "Transformer 家族",
    # Transformer+CNN 家族
    "swin_tiny_patch4_window7_224":  "Transformer+CNN 家族",
    "swin_small_patch4_window7_224": "Transformer+CNN 家族",
    "swin_base_patch4_window7_224":  "Transformer+CNN 家族",
    "swinv2_tiny_window8_256":       "Transformer+CNN 家族",
    "swinv2_small_window8_256":      "Transformer+CNN 家族",
    "caformer_s18":                  "Transformer+CNN 家族",
    "caformer_b36":                  "Transformer+CNN 家族",
    "maxvit_tiny_tf_224":            "Transformer+CNN 家族",
    "maxvit_small_tf_224":           "Transformer+CNN 家族",
    "maxvit_base_tf_224":            "Transformer+CNN 家族",
}

DISPLAY_NAMES = {
    "resnet50":                    "ResNet-50",
    "resnet101":                   "ResNet-101",
    "resnet152":                   "ResNet-152",
    "regnetx_032":                 "RegNetX-3.2G",
    "regnety_032":                 "RegNetY-3.2G",
    "convnext_tiny":               "ConvNeXt-Tiny",
    "convnext_base":               "ConvNeXt-Base",
    "convnextv2_nano":             "ConvNeXtV2-Nano",
    "convnextv2_tiny":             "ConvNeXtV2-Tiny",
    "convnextv2_base":             "ConvNeXtV2-Base",
    "tf_efficientnetv2_s":         "EfficientNetV2-S",
    "tf_efficientnetv2_m":         "EfficientNetV2-M",
    "vit_small_patch16_224":       "ViT-Small",
    "vit_base_patch16_224":        "ViT-Base",
    "deit3_small_patch16_224":     "DeiT3-Small",
    "deit3_base_patch16_224":      "DeiT3-Base",
    "eva02_small_patch14_224":     "EVA02-Small",
    "eva02_base_patch14_224":      "EVA02-Base",
    "beitv2_base_patch16_224":     "BEiTV2-Base",
    "vit_base_patch16_siglip_224": "SigLIP-Base",
    "swin_tiny_patch4_window7_224":  "Swin-Tiny",
    "swin_small_patch4_window7_224": "Swin-Small",
    "swin_base_patch4_window7_224":  "Swin-Base",
    "swinv2_tiny_window8_256":       "SwinV2-Tiny",
    "swinv2_small_window8_256":      "SwinV2-Small",
    "caformer_s18":                  "CAFormer-S18",
    "caformer_b36":                  "CAFormer-B36",
    "maxvit_tiny_tf_224":            "MaxViT-Tiny",
    "maxvit_small_tf_224":           "MaxViT-Small",
    "maxvit_base_tf_224":            "MaxViT-Base",
}

FAMILY_ORDER = ["CNN 家族", "Transformer 家族", "Transformer+CNN 家族"]
COLORS = {
    "CNN 家族":           "#E07B00",   # 橙
    "Transformer 家族":   "#3A6FD8",   # 藍
    "Transformer+CNN 家族": "#2E8B2E", # 綠
}

# ── 加工 ──────────────────────────────────────────────────────────────────
df["family"]       = df["model"].map(FAMILY_MAP)
df["display_name"] = df["model"].map(DISPLAY_NAMES)
df["acc_pct"]      = df["test/acc"] * 100
df["family_ord"]   = df["family"].map({f: i for i, f in enumerate(FAMILY_ORDER)})

# 排序（族群 → 參數量），編號 1–30
df = df.sort_values(["family_ord", "model/params_millions"]).reset_index(drop=True)
df["num"] = range(1, 31)

# ── Pareto 前緣 ───────────────────────────────────────────────────────────
def compute_pareto(df):
    s = df.sort_values("model/params_millions").reset_index(drop=True)
    best_acc, idx = -np.inf, []
    for i, row in s.iterrows():
        if row["acc_pct"] > best_acc:
            best_acc = row["acc_pct"]
            idx.append(i)
    return s.loc[idx].copy()

pareto = compute_pareto(df)

# ── 氣泡大小 ──────────────────────────────────────────────────────────────
SIZE_SCALE, SIZE_MIN = 300, 45
df["bubble"] = df["training/time_hours"] * SIZE_SCALE + SIZE_MIN

# NUM_OFFSET 已移除，改用 adjustText 自動排版

# ── 版面 ──────────────────────────────────────────────────────────────────
fig = plt.figure(figsize=(13, 12))
gs = GridSpec(2, 1, figure=fig, height_ratios=[2.3, 1.0], hspace=0.10)
ax     = fig.add_subplot(gs[0])
ax_leg = fig.add_subplot(gs[1])
ax_leg.axis("off")

# ── 散點圖 ────────────────────────────────────────────────────────────────
for family in FAMILY_ORDER:
    sub = df[df["family"] == family]
    ax.scatter(
        sub["model/params_millions"], sub["acc_pct"],
        s=sub["bubble"], c=COLORS[family],
        alpha=0.75, edgecolors="white", linewidths=0.8,
        zorder=3, label=family,
    )

# Pareto 前緣
ax.plot(
    pareto["model/params_millions"], pareto["acc_pct"],
    linestyle="--", color="#555555", linewidth=1.5, alpha=0.6,
    zorder=2, label="Pareto 前緣",
)

# 氣泡大小圖例
for hours in [0.2, 0.5, 1.0]:
    ax.scatter([], [], s=hours * SIZE_SCALE + SIZE_MIN,
               c="#bbbbbb", edgecolors="white", linewidths=0.8,
               label=f"訓練 {hours:.1f} h")

# 編號標籤：先放在氣泡中心，adjust_text 做排斥計算，事後才決定要不要畫指引線
texts = []
orig_pos = []
for _, row in df.iterrows():
    t = ax.text(
        row["model/params_millions"], row["acc_pct"],
        str(row["num"]),
        fontsize=7.5, fontweight="bold",
        ha="center", va="center", color="#111111",
        zorder=6,
        bbox=dict(boxstyle="round,pad=0.20", fc="white", ec="none", alpha=0.80),
    )
    texts.append(t)
    orig_pos.append((row["model/params_millions"], row["acc_pct"]))

# 不傳 arrowprops，先單純做文字排斥
adjust_text(
    texts,
    ax=ax,
    force_text=(0.5, 0.8),
    expand_text=(1.2, 1.4),
)

# 事後判斷：位移超過閾值才畫指引線，否則強制歸位到氣泡中心
fig.canvas.draw()
x_range = ax.get_xlim()[1] - ax.get_xlim()[0]
y_range = ax.get_ylim()[1] - ax.get_ylim()[0]
ARROW_THRESH = 0.018   # 佔軸範圍 1.8%；低於此視為「幾乎沒移動」

# 儲存 adjustText 算好的位置，再做閾值歸位
adjusted_pos = [t.get_position() for t in texts]
for t, (ox, oy), (tx, ty) in zip(texts, orig_pos, adjusted_pos):
    if abs(tx - ox) / x_range <= ARROW_THRESH and abs(ty - oy) / y_range <= ARROW_THRESH:
        t.set_position((ox, oy))

# 歸位後若仍有兩個標籤 bbox 重疊，恢復 adjustText 的離散位置
fig.canvas.draw()
renderer = fig.canvas.get_renderer()
bboxes = [t.get_window_extent(renderer) for t in texts]
for i in range(len(texts)):
    for j in range(i + 1, len(texts)):
        if bboxes[i].overlaps(bboxes[j]):
            texts[i].set_position(adjusted_pos[i])
            texts[j].set_position(adjusted_pos[j])

# 最終：對偏離原點的標籤畫指引線
fig.canvas.draw()
for t, (ox, oy) in zip(texts, orig_pos):
    tx, ty = t.get_position()
    if abs(tx - ox) / x_range > ARROW_THRESH or abs(ty - oy) / y_range > ARROW_THRESH:
        ax.annotate("", xy=(ox, oy), xytext=(tx, ty),
                    arrowprops=dict(arrowstyle="-", color="#888888", lw=0.9),
                    zorder=5)

ax.set_xlabel("參數量（百萬）", fontsize=11)
ax.set_ylabel("測試準確率（%）", fontsize=11)
ax.set_xlim(left=0)
ax.set_ylim(df["acc_pct"].min() - 0.6, df["acc_pct"].max() + 0.7)
ax.grid(True, linestyle=":", alpha=0.35, zorder=1)
ax.tick_params(labelsize=9)
ax.legend(loc="lower right", fontsize=8.5, framealpha=0.92,
          edgecolor="#cccccc", borderpad=0.9, ncol=2)

# ── 數字對照表（下方三欄） ────────────────────────────────────────────────
# 欄位分佈：1-10 | 11-20 | 21-30
# 數字右對齊到固定位置，名稱統一從同一 x 開始，避免位數不同造成歪斜
COL_X     = [0.00, 0.34, 0.67]   # 每欄起始 x（axes fraction）
NUM_WIDTH = 0.040                  # 數字欄固定寬度（右邊界 = cx + NUM_WIDTH）
Y_START   = 0.96
Y_STEP    = 0.100

for col_idx, cx in enumerate(COL_X):
    lo = col_idx * 10 + 1
    col_df = df[df["num"].between(lo, lo + 9)]
    y = Y_START
    for _, row in col_df.iterrows():
        c = COLORS[row["family"]]
        # 數字右對齊，確保「.」永遠在同一 x
        ax_leg.text(cx + NUM_WIDTH, y, f"{row['num']}.",
                    transform=ax_leg.transAxes,
                    fontsize=9.5, color=c, fontweight="bold",
                    va="top", ha="right")
        # 名稱從固定 x 開始
        ax_leg.text(cx + NUM_WIDTH + 0.008, y, row["display_name"],
                    transform=ax_leg.transAxes,
                    fontsize=9.5, color="#111111", va="top", ha="left")
        y -= Y_STEP

# 底部族群色塊說明（留足夠空白與表格最後一行隔開）
Y_COLOR = Y_START - 10 * Y_STEP - 0.02   # 比最後一行再低一格
ax_leg.text(0.01, Y_COLOR, "顏色：",
            transform=ax_leg.transAxes, fontsize=8.5,
            va="top", color="#444444")
x_pos = 0.09
for fam in FAMILY_ORDER:
    ax_leg.text(x_pos, Y_COLOR, f"■ {fam}   ",
                transform=ax_leg.transAxes, fontsize=8.5,
                va="top", color=COLORS[fam])
    x_pos += 0.28

# ── 儲存 ─────────────────────────────────────────────────────────────────
# 請改為你的論文 images 目錄
OUT = "images/backbone_scatter.png"
plt.savefig(OUT, dpi=200, bbox_inches="tight")
print(f"已儲存至 {OUT}")
plt.close()
