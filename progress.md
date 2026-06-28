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
