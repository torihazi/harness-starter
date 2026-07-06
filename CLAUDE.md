# Harness — 運用ルール (CLAUDE.md)

このプロジェクトは「長時間タスクを複数セッションにまたいで完遂する」ためのハーネスです。
モデル本体ではなく、この CLAUDE.md / agents / 状態ファイル群が "成否を決めるスキャフォールド" です。

メンタルモデル: ハーネス = モデル以外の全部。各部品は「今のモデルの弱点を補う一時的な足場」であり、
過剰に作り込まず最小限を狙う。

---

## 1. メンタルモデル (Fowler の 2×2)

|                          | Computational (決定的・速い)        | Inferential (AI判断・遅い)            |
| ------------------------ | ----------------------------------- | ------------------------------------- |
| Guide (事前に方向づけ)   | 型 / 規約 / `init.sh` / テンプレート / `DESIGN.md` | `planner` / `designer` (DESIGN.md を所有) |
| Sensor (事後に問題検知)  | lint / test / typecheck / DESIGN.md validate (`check.sh`)| `evaluator`                           |

原則: **速くて確実な検証は機械 (Computational) に任せ、AI エージェントは機械にできない意味判断だけに使う。**

UIアプリの視覚デザインは `DESIGN.md` (Google の DESIGN.md 形式) に固定する。これは Inferential Guide (`designer`)
が所有する成果物だが、機械可読な design token を持ち CLI で validate できるため、視覚の Computational Sensor にもなる。

---

## 2. 状態ファイル (コンテキスト外の記憶)

セッションをまたぐ記憶は会話履歴ではなく以下のファイルに置く。会話コンテキストは揮発する前提で扱う。

- `features.json` — 機能リスト・受け入れ基準・**sprint (関連機能を束ねた計画上のグルーピング。承認/PR/go-no-go の単位は機能)**。**ここが唯一の信頼できる進捗ソース (single source of truth)**。
  - 各機能の `status` は `failing | passing` のみ。初期値は必ず `failing`。
  - `sprints[]` は順序付きのグルーピング。各 sprint の `status` は `planned | in_progress | done` (進捗可視化用の帳簿。sprint 内の全機能が passing になったら `done`)。planner が切り、人間が plan 全体を1回承認する。go/no-go は sprint 単位ではなく機能単位で取る。
  - **テストや受け入れ基準を削除・緩和してはならない。** 通すのはコードであって基準ではない。
  - Markdown ではなく JSON にしているのは、モデルが不用意に書き換えにくくするため。
- `progress.md` — 直近で何をしたか / 次に何をするか / 既知の問題 のメモ。
- git 履歴 — リカバリポイント。壊れたらコミットへ巻き戻す。
- `init.sh` — 依存インストールなどの環境構築。各セッション開始時に実行する。
  **サーバ起動はしない** (毎セッション起動するとポート競合するため)。e2e/ブラウザ検証で必要な時は `evaluator` が自分で起動する。
- `DESIGN.md` — (UIアプリのみ) ビジュアルアイデンティティ仕様。Google の DESIGN.md 形式 = YAML front matter の
  design token (機械可読・CLIで validate) + Markdown の rationale (理由)。`designer` が所有し repo に vendoring する。
  色・タイポ・余白は直書きせず、export したトークンを参照する。alpha 仕様なのでバージョンを固定する。
  上流ソースは複数可 (claude design のワイヤフレーム HTML/画像 / getdesign.md / 公式仕様) だが、**値の SoT は常に `DESIGN.md`**。
  受け取ったワイヤフレームは `design/` に vendoring してレイアウト参照に使い (画像より HTML が望ましい)、値が食い違えば `DESIGN.md` が勝つ。

---

## 3. セッション開始ルーチン (毎回必ず実行)

1. `pwd` で作業ディレクトリを確認する。
2. `git log --oneline -10` と `progress.md` を読み、文脈を復元する。
3. `features.json` で現在地を特定する:
   - **承認済みの plan がまだ無いなら §4 の plan フェーズから始める** (勝手に execute に入らない)。
   - 承認済み plan があるなら、`status: "failing"` かつ `depends_on` 充足済みの最優先の機能を、次の1つとして選ぶ (sprint は所属を示すグルーピングであって、選択の単位ではない)。
   - 直前の機能が go 待ち (PR 未マージ) で止まっているなら、まずそれを片付ける。
4. `./init.sh` で依存関係・環境を整える (サーバは起動しない)。
5. **新しい作業を始める前に** `./scripts/check.sh` と既存 e2e テストを走らせ「今ちゃんと動くか」を確認する。
   - ここで壊れていたら、新機能より先にそれを直す。

---

## 4. ループ (plan は最初に書き切り、承認後は機能ごとに execute→evaluate→PR→go/no-go)

ループの流れ (概略):

`plan(全機能 + sprint 分割) → 人間が1回承認 → [機能ごと: execute → evaluate → passing で commit → PR → go/no-go → 次機能] → done`

登場人物は Planner / Designer (UIのみ) / Executor / Evaluator。承認・sprint 分割・PR・go/no-go・停止条件などの詳細は下の 4.1〜4.5 と §5 を正とする。

### 4.1 plan — 最初に1回、全部書き切る
- `planner` がゴールを **全機能に分解** し、受け入れ基準を `features.json` に書く。
- さらに機能を **順序付きの sprint に束ねる** (`sprints[]`)。各 sprint は「関連機能を束ねた計画上のまとまり」で切る (進捗の可視化・見通し用。PR/go-no-go は機能単位なので、sprint は "PR の単位" ではない)。
- (UIアプリのみ) design が要るなら plan に **designer ステップを明記**してよい (例: `design/` のワイヤフレームから `DESIGN.md` を起こす)。`designer` が `DESIGN.md` を選定/生成・validate・所有する (新規 or 変更時のみ・人間が故意に呼ぶ)。ソフトウェア構造 (アーキテクチャ / 技術選定) の判断は `planner` 側に寄せる。

### 4.2 承認ゲート — plan は1回だけ
- ファイルを書き換える *前に*、人間が **plan 全体 (全機能 + sprint 分割)** を承認する (Explore/Plan は自由、Execute の手前で止める)。
- **plan の承認は1回だけ** (方針を小出しに承認しない)。承認されたら execute に入るが、実行の刻みは機能単位で、**各機能の PR 後に go/no-go を取る** (§4.3)。executor↔evaluator の反復は自律で回すが、機能が passing になるたび人間の go/no-go で一区切りする。

### 4.3 機能ループ — 承認後、本体セッションが機能を1つずつ回す
承認済み plan の failing 機能を、優先度順・`depends_on` 充足順に **一度に1つだけ** 選ぶ。各機能について:

1. 本体セッションが **`feature/<F-id>-<slug>` 作業ブランチを切る** (最新の main から分岐)。以降この機能はこのブランチ上で進める。
2. `executor` が実装する (自己採点しない)。
3. `evaluator` が独立に採点する。`failing` ならエラー全文フィードバックを `executor` に戻して反復する (上限 §5)。
4. `passing` になったら `features.json` の当該機能を `passing` にし、**その機能単位で git commit** して **その機能の PR を出す** (差分は1機能分)。
5. **go/no-go チェックポイント**: 人間に「この機能をマージして次へ進むか」を確認する。
   - **go**: PR を main にマージする。次の failing 機能は **マージ後の main から** 分岐する (`depends_on` は main 経由で解決)。
   - **no-go / 修正要望**: §4.4 の再突入へ。
6. その機能が属する sprint の全機能が `passing` になったら、`sprints[]` の当該 sprint を `done` にする (帳簿更新のみ。承認ゲートではない)。

### 4.4 停止条件 — 自律ループから人間へ戻す
以下のいずれかで **必ず止まって人間へ返す**:
- 同一機能で **5 イテレーション失敗** (§5)。
- plan が想定していない **ブロッカー / 曖昧さ / スコープ外の判断** が要るとき。基準を勝手に緩めず、スコープを勝手に広げない。
- **各機能の go/no-go** (PR を出した後、マージ前)。

**no-go / 修正要望からの再突入**: 人間が「ここがこうなってない」と直しを求めたら、口頭のまま実装に入らない。まず **その要望を受け入れ基準として `features.json` に書き起こす** (基準の更新は `planner`。足りない要件なら新機能として追加)。次に **該当機能の `status` を `passing` → `failing` に戻す**。その上で **§4.3 の機能ループへ再突入** し、`executor` が差分だけ実装 → `evaluator` が更新後の基準で採点する。**同じ機能の作業ブランチ / PR に差分 commit を積む** (別機能へは進まない)。口頭の要望を基準へ落としてから動くのは、**生成≠評価 / 完了宣言の禁止** (§5) を保つため (曖昧な「なんかダメ」のまま通さない)。

### 4.5 各機能終了時の必須事項
- 環境を clean state (production-ready) に戻す。
- `progress.md` を更新する (どの sprint / 機能 / evaluator 判定)。
- **commit も PR も機能ごと。** main へ直接 commit せず、機能ごとに作業ブランチを切る (`feature/<F-id>-<slug>`)。go で main にマージし、次機能はマージ後の main から分岐する。
- `evaluator` が `passing` を出した機能だけ `features.json` の `status` を更新する。

---

## 5. 動作基準 (ハードルール)

- **完了宣言の禁止**: `evaluator` が `passing` を出すまで、executor は機能を完了扱いにしてはならない。
- **1 機能ずつ (逐次)**: 複数機能を *同時* に実装しない (コンテキスト枯渇と未完了の原因)。承認後も機能を1つずつ処理し、各機能の PR 後に go/no-go で一区切りする (1セッションで複数機能を順に処理してよいが、機能をまたいで並行はしない)。
- **生成 ≠ 評価**: 生成したエージェントに評価させない。
- **ループ上限**: 同一機能で 5 イテレーション失敗したら停止し、`progress.md` に状況を書いて人間へエスカレーションする。
- **承認は plan 1回 + 機能ごとの go/no-go**: 人間の承認は「plan 全体を1回」。以降は各機能の PR 後に go/no-go を取る。executor↔evaluator の反復は自律で回すが、機能が passing になるたびマージ判断で一区切りする。
- **commit も PR も機能ごと**: 機能が passing になるたびに commit し、その機能の PR を出す。main へ直接 commit せず機能ごとに作業ブランチを切る (`feature/<F-id>-<slug>`)。go でマージし、次機能はマージ後の main から分岐する。
- **勝手に広げない**: 停止条件 (§4.4) に当たったら自律実行を止めて人間へ返す。基準の緩和・スコープ拡大・想定外の判断を独断で行わない。
- **エラーはそのまま渡す**: 失敗時は stack trace / エラー全文を次のエージェントへ渡す (要約しすぎない)。
- **重い探索はサブエージェントへ**: executor は広いコード探索をサブエージェントに委譲し、本体には 1,000〜2,000 トークンの凝縮要約だけを返させる。
- **JIT コンテキスト**: 最初から全部読み込まない。パス / クエリだけ持ち、必要時に動的ロードする。
- **再発したら supervision でなくハーネスを直す**: 同じ失敗が繰り返されたら、人手レビューを増やすのではなく Guide / Sensor (この CLAUDE.md・check.sh・agents) を改善する。
- **UI は DESIGN.md に準拠**: (UIアプリのみ) 色・タイポ・余白・コンポーネントは `DESIGN.md` のトークンに従う。値を直書きせず export したトークン (Tailwind / CSS 変数等) を使う。UI ライブラリ (shadcn/ui, MUI 等) を採用する場合も `DESIGN.md` のトークンはソースオブトゥルースのまま維持し、そのライブラリのテーマ機構 (Tailwind config / CSS 変数 / JS テーマオブジェクト等) へのマッピング層だけを置き換える。`DESIGN.md` を変更してよいのは `designer` だけ。
- **DESIGN.md は vendoring + バージョン固定**: 実行時に外部から取得しない。alpha 仕様なので固定し、更新時のみ `designer` が差し替える。
- **プレースホルダのまま UI を作らない**: テンプレ同梱の `DESIGN.md` はプレースホルダ。UIアプリでは `designer` が実物 (claude design のワイヤフレーム / getdesign.md / designmd.app) へ差し替えてから UI を実装する。ワイヤフレームは `design/` に vendoring し、値は `DESIGN.md` に書き起こす (値の SoT は `DESIGN.md`)。UI が無いアプリでは `DESIGN.md` を削除する。差し替え忘れは `check.sh` が警告する。
