# Progress Log

コンテキスト外の記憶。各イテレーションの終わりに追記する。会話履歴は揮発する前提。

## 書式
```
## YYYY-MM-DD HH:MM — <sprint-id>/<feature-id> <タイトル>
- やったこと:
- 次の一手:
- 既知の問題 / ブロッカー:
- evaluator 判定: passing | failing (failing なら理由)
```

---

## 2026-06-28 — 初期化
- やったこと: ハーネスのスキャフォールドを生成 (CLAUDE.md / agents / features.json / init.sh / check.sh)。
- 次の一手: planner を呼んで F-001 のサンプルを本物の機能に置き換える。
- 既知の問題: まだ実装対象のアプリ本体が無い (テンプレート状態)。
- evaluator 判定: N/A

## 2026-06-29 — DESIGN.md を視覚デザインの基盤に採用
- やったこと: designer を「DESIGN.md を所有する視覚デザイン役」に再定義。アーキ判断は planner に寄せた。
  DESIGN.md プレースホルダ追加、check.sh に視覚 validate (alpha・コメント) 追加、CLAUDE.md/README/features.json 更新。
- 根拠: DESIGN.md は YAML token (機械可読) + Markdown rationale のハイブリッドで、ハーネスの「契約+物語」分割に合致。
  CLI validate により視覚の Computational Sensor が得られ、designer の正当性が ★☆☆ → ★★☆ に上がる。
- 既知の問題: DESIGN.md は alpha 仕様。公式 CLI の正確なコマンド名は google-labs-code/design.md で要確認 (check.sh は当面コメント)。
- evaluator 判定: N/A (テンプレート更新のため)

## 2026-07-01 — sprint 単位の自律実行フローを導入
- やったこと: 「plan を最初に全部書き切り → 人間が1回承認 → 承認後は sprint 単位で自律実行 (execute→evaluate→機能ごと commit→sprint ごと PR→go/no-go)」へループを再設計。
  features.json に sprints[] (planned|in_progress|done) と機能の sprint フィールドを追加。CLAUDE.md §3/§4/§5、planner.md、README を同期。
- 根拠: 承認ゲートを「機能ごと」から「plan 全体で1回 + sprint 境界の go/no-go」へ付け替え、1セッションで複数機能を逐次に走り切れるようにした。
  中核の安全則 (生成≠評価・完了宣言禁止・5回失敗で停止) は維持。ドライバは本体セッション (最小・可逆)。
- 次の一手: 実アプリで planner を呼び、サンプル (S-1 / F-001 / F-002) を本物の sprint・機能に置き換える。
- evaluator 判定: N/A (テンプレート更新のため)

## 2026-07-04 — model 使い分けとサーバ起動責務の整理
- やったこと:
  - `executor` の model を opus → sonnet に変更。planner/designer/evaluator は opus 維持。
    (「計画・評価は賢さ優先、実装は反復が多いのでコスト/速度を優先」という判断)
  - サーバ起動の責務を `init.sh` から `evaluator` へ移動。`init.sh` は依存インストール等の環境構築のみを担い、
    毎セッション実行してもポート競合しないようにした。e2e/ブラウザ検証が要る機能では `evaluator` が
    起動済みか確認した上で自分で立ち上げる。CLAUDE.md §2/§3, README, init.sh, evaluator.md を同期。
  - sprint ブランチ (`sprint/<S-id>-<slug>`) を切るタイミングを CLAUDE.md §4.3 に明記 (sprint を `in_progress`
    にした直後、本体セッションが行う)。
- 根拠: テンプレをそのまま撮影・配布する前提のレビューで発見した3点 (ブランチ作成タイミングの未記載、
  check.sh の二重実行、4エージェント一律 opus) のうち、影響が大きい2点を人間と協議して確定した。
  check.sh の二重実行は実害が無いため今回は据え置き。
- 次の一手: 実アプリ (積読管理アプリ) の企画プロンプトを本番セッションで投入し、`planner` から開始する。
- evaluator 判定: N/A (テンプレート更新のため)
