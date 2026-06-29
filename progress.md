# Progress Log

コンテキスト外の記憶。各イテレーションの終わりに追記する。会話履歴は揮発する前提。

## 書式
```
## YYYY-MM-DD HH:MM — <feature-id> <タイトル>
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
