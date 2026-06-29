#!/usr/bin/env bash
# check.sh — Computational Sensor。lint / typecheck / test を決定的に実行する。
# 速くて確実な検証は機械に任せ、AI エージェント (evaluator) は意味判断に集中させる。
# 1つでも失敗したら非ゼロで終了する。
set -uo pipefail

fail=0
run () {
  echo "──▶ $*"
  if ! "$@"; then echo "✗ failed: $*"; fail=1; else echo "✓ ok: $*"; fi
}

# プロジェクトに合わせてコメントを外す:
# run npm run lint
# run npm run typecheck
# run npm test
# run ruff check .
# run mypy .
# run pytest -q

# DESIGN.md 視覚 Sensor (UIアプリのみ。alpha 仕様。正確なコマンドは google-labs-code/design.md で確認):
# [ -f DESIGN.md ] && run npx design-md validate DESIGN.md

# DESIGN.md プレースホルダ差し替え忘れの保険 (警告のみ、check は止めない):
if [ -f DESIGN.md ] && grep -q "PLACEHOLDER" DESIGN.md; then
  echo "⚠ DESIGN.md がプレースホルダのまま — getdesign.md の実物へ差し替えるか、UIが無ければ削除する (README参照)"
fi

if [ "$fail" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "SOME CHECKS FAILED"
fi
exit "$fail"
