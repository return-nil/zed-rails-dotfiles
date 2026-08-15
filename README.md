# Zed Rails dotfiles

自宅と仕事のMacで、Zedを使ったRails開発環境を再現するための設定です。

## 復元されるもの

- Zedの表示・Gitパネル・インライン診断設定
- Zedのキーマップ
- Ruby LSPとRuboCopだけを使うRailsプロジェクト設定
- `code .` でZedを開くシェル設定
- Ruby、Rust、Zed周辺ツールの導入手順

Zedのキャッシュ、ログイン情報、GitHubの認証情報、言語サーバーのダウンロード済みバイナリは管理しません。新しいPCで再インストールします。

## 新しいMacでのセットアップ

### 1. 基本ツール

[Homebrew](https://brew.sh/)をインストールしたあと、このリポジトリで実行します。

```bash
brew bundle
```

RustとCargoは、Rust公式の`rustup`でインストールします。

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

### 2. Zed設定

```bash
./scripts/install.sh
```

既存の`settings.json`と`keymap.json`がある場合は、削除せず同じ場所へバックアップしてからシンボリックリンクを作ります。`~/.zshrc`にも読み込み設定を追記します。

Zedを起動後、コマンドパレットから`cli: install cli binary`を一度実行してください。

### 3. Railsプロジェクト

Railsプロジェクトのルートで実行します。

```bash
mkdir -p .zed
cp /path/to/zed-rails-dotfiles/templates/rails/.zed/settings.json .zed/settings.json
bundle install
```

プロジェクト固有のRubyバージョンは、各プロジェクトの`.ruby-version`に従って`rbenv`などでインストールします。

### 4. Railsの動的メソッドへ定義ジャンプするgem

必要なRailsプロジェクトの`Gemfile`へ追加します。

```ruby
group :development do
  gem "ruby-lsp-rails-runtime-definitions",
    github: "return-nil/ruby-lsp-rails-runtime-definitions",
    require: false
end
```

その後、依存関係をインストールします。

```bash
bundle install
```

### 5. 任意: fuzzy-ruby-server

大規模Rubyコードベース向けの言語サーバーを試す場合だけインストールします。

```bash
cargo install --locked --git https://github.com/doompling/fuzzy_ruby_server
```

現在のRailsテンプレートでは`ruby-lsp`と`rubocop`だけを有効にしているため、インストールしただけでは起動しません。

## 動作確認

```bash
./scripts/doctor.sh
```

Railsプロジェクトでは、追加で次を確認します。

```bash
bundle exec rubocop -V
```

## セキュリティ上の注意

現在のZed設定には`trust_all_worktrees: true`が含まれます。すべてのworktreeを確認なしで信頼する設定なので、信頼できないリポジトリを開くPCでは`false`へ変更してください。

APIキー、アクセストークン、SSH鍵、ZedやGitHubのログイン情報は、このリポジトリへ追加しないでください。
