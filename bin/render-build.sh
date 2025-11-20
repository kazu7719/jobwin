#!/usr/bin/env bash
set -o errexit  # どこかで失敗したらそこで止める

# 1. Rubyの依存インストール
bundle install

# 2. （フロントがあれば）JS/CSSのビルド
# package.json があって yarn を使っているならコメントアウトを外す
# yarn install
# yarn build

# 3. アセットプリコンパイル
bundle exec rails assets:precompile

# 4. ★ここで本番DBにマイグレーションを流す★
bundle exec rails db:migrate