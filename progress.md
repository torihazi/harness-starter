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

## 2026-07-06 — go/no-go と PR を機能単位へ戻す (sprint は計画グルーピングに降格)
- やったこと: 承認後の刻みを「sprint 単位の自律実行 + sprint 境界 go/no-go + sprint ごと PR」から
  「機能ごとに execute→evaluate→passing で commit→機能ごと PR→機能ごと go/no-go」へ戻した。
  ブランチも `sprint/<S-id>-<slug>` → `feature/<F-id>-<slug>` に変更 (go で main にマージし、次機能はマージ後の main から分岐)。
  `sprints[]` は残すが「関連機能を束ねた計画上のグルーピング (進捗可視化用の帳簿)」に降格し、承認/PR/go-no-go の単位からは外した。
  CLAUDE.md §2/§3/§4.1〜4.5/§5、features.json の rules・サンプル goal、planner.md、README を同期。
- 根拠: sprint 内の全機能を1本の PR にまとめると変更差分が大きくなりレビューしづらい、という指摘。
  差分を1機能分に縮め、各機能で go/no-go を挟んでレビュー粒度を細かくした。plan 全体の1回承認は維持 (計画の一貫性)。
  中核の安全則 (生成≠評価・完了宣言禁止・5回失敗で停止) は不変。
- 既知の問題: 機能数が多いと PR/go-no-go の回数が増える (差分の小ささとのトレードオフで、意図的に受け入れる)。
- evaluator 判定: N/A (テンプレート更新のため)

## 2026-07-06 — executor の model を sonnet → opus に戻す
- やったこと: `executor.md` の `model` を sonnet から opus に変更。これで planner/designer/evaluator/executor の
  4エージェント全てが opus に揃った。
- 根拠: 2026-07-04 に「実装は反復が多いのでコスト/速度優先」で sonnet に落としていたが、executor は
  コードの正しさを生む本体で、5回失敗すると人間へエスカレーションして節約以上に時間を溶かすリスクがある。
  Opus 4.8 は高速なため全 opus でも実害が小さいと判断し、一発精度を優先して opus に戻した。
- 既知の問題: executor↔evaluator の自律ループでコスト/レイテンシが上がる。失敗ループが目立たない限りは許容。
- evaluator 判定: N/A (テンプレート更新のため)
