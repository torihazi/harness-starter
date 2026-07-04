#!/usr/bin/env bash
# init.sh — 環境構築 (依存インストール等)。各セッション開始時に実行する。
# サーバ起動はここではしない (毎セッション起動するとポート競合するため)。
# e2e/ブラウザ検証で必要な時は evaluator が自分で起動する。
# Computational Guide: 「アプリを動く状態に戻す」手順を決定的に固定し、
# エージェントが毎回それを再発見して時間を溶かすのを防ぐ。
set -euo pipefail

echo "[init] working dir: $(pwd)"

# --- 依存インストール (プロジェクトに合わせて1つ選ぶ) ---
# [ -f package.json ]        && npm install
# [ -f requirements.txt ]    && pip install -r requirements.txt
# [ -f pyproject.toml ]      && uv sync

echo "[init] done. ここにプロジェクト固有のセットアップを記述する。"
