# harness-starter

長時間タスクを複数セッションにまたいで完遂するための、汎用エージェント・ハーネスのスターター。
「モデル本体ではなく、その周りのスキャフォールドが成否を決める」という前提で組んである。

> **このリポジトリは master テンプレート。** ここで直接アプリを作るのではなく、
> 新しいアプリごとにこのテンプレートから複製して使う (下の「新しいアプリを始める」を参照)。

## 構成

```
harness-starter/
├── CLAUDE.md            # ループ定義・セッション開始ルーチン・動作基準 (ハーネスの中心)
├── features.json        # 機能リスト+受け入れ基準 = 唯一の信頼できる進捗ソース
├── progress.md          # コンテキスト外の記憶 (やったこと/次の一手/既知の問題)
├── init.sh              # 環境構築・サーバ起動 (Computational Guide)
├── scripts/
│   └── check.sh         # lint/typecheck/test = Computational Sensor
└── .claude/
    ├── settings.json    # hooks: 編集後に check.sh を自動発火
    └── agents/
        ├── planner.md   # WHAT を決める   (Inferential Guide)
        ├── designer.md  # HOW を決める    (Inferential Guide)
        ├── executor.md  # 1機能ずつ実装    (実行)
        └── evaluator.md # 独立に採点       (Inferential Sensor)
```

## メンタルモデル (Fowler の 2×2)

|                     | Computational (決定的・速い) | Inferential (AI判断・遅い) |
| ------------------- | ---------------------------- | -------------------------- |
| Guide (事前)        | 型 / 規約 / init.sh          | planner / designer         |
| Sensor (事後)       | lint / test (check.sh)       | evaluator                  |

速くて確実な検証は機械に任せ、AI は機械にできない意味判断だけに使う。

## ループ

```
plan → (人間の承認) → design → execute → evaluate → (failing なら feedback して戻る)
```

- 承認ゲートは Plan と Execute の間に置く (探索・計画は自由、ファイル変更の手前で止める)。
- 生成 (executor) と評価 (evaluator) は必ず分離する。
- 一度に 1 機能だけ。evaluator が passing を出すまで完了扱いにしない。

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
2. `git add -A && git commit -m "init"` でベースラインを作る。
3. このディレクトリで Claude Code を起動する (この階層の CLAUDE.md / .claude が効く)。
4. planner を呼び、`features.json` のサンプル F-001 を本物の機能に置き換える。
5. CLAUDE.md の「セッション開始ルーチン」「ループ」に従って回す。

## テンプレート自体を改善する (master を更新)

ハーネスの仕組み (CLAUDE.md / agents / check.sh など) を良くしたくなったら、
この master リポジトリ (`torihazi/harness-starter`) を直接編集して commit / push する。
次に複製するアプリから改善が効く。

## 設計思想

各部品は「今のモデルの弱点を補う一時的な足場」。モデルが賢くなれば不要になる前提で、過剰に作り込まない。
同じ失敗が繰り返されたら、人手レビューを増やすのではなく Guide / Sensor (CLAUDE.md・check.sh・agents) を改善する。
