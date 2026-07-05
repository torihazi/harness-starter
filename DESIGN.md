---
# DESIGN.md — ビジュアルアイデンティティ仕様 (Google DESIGN.md 形式 / alpha)
#
# PLACEHOLDER — UI を作る前に必ず実物へ差し替えること (UI が無ければこのファイルを削除)。
# これはプレースホルダ。designer が以下のいずれかで置き換える:
#   - claude design (claude.ai/design) のワイヤフレーム HTML/画像から値を書き起こす (HTML 推奨・design/ に vendoring)
#   - getdesign.md / designmd.app のカタログから近いものを選ぶ
#   - 公式 CLI (google-labs-code/design.md) で生成・validate する
# 値の SoT は常にこの DESIGN.md。ワイヤフレームは上流入力＋レイアウト参照で、食い違えば DESIGN.md が勝つ。
# 正確なトークンスキーマは公式仕様 (alpha・変わりうる) を参照し、バージョンを固定すること:
#   https://github.com/google-labs-code/design.md
meta:
  name: my-app
  version: 0.1.0
colors:
  background: "#ffffff"
  foreground: "#1a1a1a"
  primary: "#000000"
  accent: "#c8553d"        # 例: warm terracotta
  muted: "#6b6b6b"
typography:
  fontFamily: "system-ui, sans-serif"
  scale:
    base: "16px"
    h1: "40px"
    h2: "28px"
spacing:
  unit: "4px"
  scale: ["4px", "8px", "12px", "16px", "24px", "32px", "48px"]
radius:
  sm: "4px"
  md: "8px"
  lg: "16px"
components:
  button:
    background: primary
    foreground: background
    radius: md
    padding: ["8px", "16px"]
  card:
    background: background
    radius: lg
    shadow: "0 1px 3px rgba(0,0,0,0.1)"
---

# Design Rationale

> これはプレースホルダの理由書。実プロジェクトでは designer が置き換える。

## 世界観
(例) クリーンなエディトリアルレイアウト + 知的で落ち着いた印象。warm terracotta を差し色に使う。

## 適用ルール
- 色・余白・角丸・コンポーネントは上のトークンを使い、各所で値を直書きしない。
- 新しいページも同じトークンセットに従い、visual identity を一貫させる。
- トークンの変更は designer のみが行い、`DESIGN.md` を更新して validate する。
