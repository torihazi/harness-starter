# harness-starter

長時間タスクを複数セッションにまたいで完遂するための、汎用エージェント・ハーネスのスターター。
「モデル本体ではなく、その周りのスキャフォールドが成否を決める」という前提で組んである。

> **このリポジトリは master テンプレート。** ここで直接アプリを作るのではなく、
> 新しいアプリごとにこのテンプレートから複製して使う (下の「新しいアプリを始める」を参照)。

## 構成

```
harness-starter/
├── CLAUDE.md            # ループ定義・セッション開始ルーチン・動作基準 (ハーネスの中心)
├── features.json        # 機能リスト+受け入れ基準+sprint = 唯一の信頼できる進捗ソース
├── progress.md          # コンテキスト外の記憶 (やったこと/次の一手/既知の問題)
├── DESIGN.md            # 視覚アイデンティティ (Googleの DESIGN.md形式・UIアプリのみ/任意)
├── init.sh              # 環境構築 (依存インストール等。サーバは起動しない) (Computational Guide)
├── scripts/
│   └── check.sh         # lint/typecheck/test/DESIGN.md validate = Computational Sensor
└── .claude/
    ├── settings.json    # hooks: 編集後に check.sh を自動発火
    └── agents/
        ├── planner.md   # WHAT + 軽量な構造判断 (Inferential Guide)
        ├── designer.md  # DESIGN.md (視覚) を所有  (Inferential Guide / UIのみ)
        ├── executor.md  # 1機能ずつ実装           (実行)
        └── evaluator.md # 独立に採点              (Inferential Sensor)
```

## メンタルモデル (Fowler の 2×2)

|                     | Computational (決定的・速い) | Inferential (AI判断・遅い) |
| ------------------- | ---------------------------- | -------------------------- |
| Guide (事前)        | 型 / 規約 / init.sh / DESIGN.md | planner / designer         |
| Sensor (事後)       | lint / test / DESIGN.md validate (check.sh) | evaluator     |

速くて確実な検証は機械に任せ、AI は機械にできない意味判断だけに使う。

## ループ

```
plan(全機能 + sprint 分割) → 人間が1回承認 → [sprint ごと: 機能ループ(execute → evaluate → 機能ごと commit) → PR → go/no-go] → 次 sprint
```

- **plan は最初に書き切る**: planner が全機能へ分解し、順序付きの sprint に束ねる。承認は plan 全体で1回だけ。
- 承認後は本体セッションが sprint を自律的に回す。止まるのは「同一機能で 5 回失敗」「想定外ブロッカー」「sprint 境界の go/no-go」のときだけ。
- 生成 (executor) と評価 (evaluator) は必ず分離する。機能は逐次に1つずつ (同時実装はしない)。
- commit は機能ごと、PR は sprint ごと。evaluator が passing を出すまで完了扱いにしない。

## ビジュアルデザイン (DESIGN.md) — UIアプリのみ

UI を持つアプリでは、ビジュアルアイデンティティを `DESIGN.md` (Google Labs が OSS 公開した形式) に固定する。
これにより「毎回ジェネリックな AI レイアウト / ページ間で見た目がバラバラ」という失敗を防ぐ。

- **形式**: YAML front matter の design token (色 / タイポ / 余白 / 角丸 / コンポーネント、機械可読) + Markdown の rationale。
- **依存先**: 公式仕様 [`google-labs-code/design.md`](https://github.com/google-labs-code/design.md) を主にする (Apache 2.0・alpha)。
  [getdesign.md](https://getdesign.md/) / [designmd.app](https://designmd.app/) のカタログは「初期トークンの調達元」として従に使う。
- **所有者**: `designer` だけが `DESIGN.md` を変更する。`executor` は export したトークンを参照し、色・余白を直書きしない。
- **検証**: 公式 CLI の validate を `check.sh` に足すと、視覚の Computational Sensor になる。`evaluator` は描画して準拠を確認する。
- **運用**: 結果の `DESIGN.md` は repo に vendoring (コミット) し、実行時に外部取得しない。alpha なのでバージョンを固定する。
- **注意**: カタログは実在ブランドの解析。インスピレーション用途に留め、特定ブランドへの酷似は trade dress 上の配慮をする。

CLI / バックエンド / ライブラリなど UI の無いアプリでは `DESIGN.md` も `designer` も不要。

## 新しいアプリを始める

このテンプレートから複製する。複製先がアプリの repo になる。

### 方法 A: GitHub テンプレートから (おすすめ)

```bash
gh repo create my-app --template torihazi/harness-starter --private --clone
cd my-app
```

### 方法 B: クローンしてコピー

```bash
git clone https://github.com/torihazi/harness-starter.git
cp -r harness-starter my-app && rm -rf my-app/.git
cd my-app && git init
```

## ブートストラップ (複製後に1回だけ)

1. `init.sh` / `scripts/check.sh` を技術スタックに合わせて埋める (実行権限は付与済み)。
2. このディレクトリで Claude Code を起動する (この階層の CLAUDE.md / .claude が効く)。
3. **(UIアプリなら) `DESIGN.md` を実物へ差し替える** — `designer` を呼び、[getdesign.md](https://getdesign.md/) /
   [designmd.app](https://designmd.app/) から世界観の近いものを取得 (`npx getdesign@latest add <name>` 等) して
   プレースホルダを置換 → validate → commit。**UI が無いアプリなら `DESIGN.md` を削除する。**
   (差し替え忘れると `check.sh` が警告を出す。)
4. `planner` を呼び、`features.json` のサンプル (F-001 / UIの例 F-002) を本物の機能に置き換える。
5. `git add -A && git commit -m "init"` でベースラインを作る。
6. CLAUDE.md の「セッション開始ルーチン」「ループ」に従って回す。

## テンプレート自体を改善する (master を更新)

ハーネスの仕組み (CLAUDE.md / agents / check.sh など) を良くしたくなったら、
この master リポジトリ (`torihazi/harness-starter`) を直接編集して commit / push する。
次に複製するアプリから改善が効く。

## 設計思想

各部品は「今のモデルの弱点を補う一時的な足場」。モデルが賢くなれば不要になる前提で、過剰に作り込まない。
同じ失敗が繰り返されたら、人手レビューを増やすのではなく Guide / Sensor (CLAUDE.md・check.sh・agents) を改善する。
