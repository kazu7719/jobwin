#!/usr/bin/env bash
# exit on error（どこかで失敗したらそこで止める）
set -o errexit

# 1. 依存ライブラリをインストール
bundle install

# 2.（もし Node/Yarn 使っていたら）フロント側のビルド
# package.json があるならコメントアウトを外して使ってOKです
# yarn install
# yarn build

# 3. アセットのプリコンパイル（CSS/JS）
bundle exec rails assets:precompile