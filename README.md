# Rails Development Dotfiles

Zed、Ghostty、Herdrを使ったRails開発環境を再現するための設定です。

## 復元されるもの

- Zedの表示・Gitパネル・インライン診断設定
- Zedのキーマップ
- Ghosttyの表示・macOSキーボード設定
- 現在行を変更したGitHub PRを開くショートカット
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

### 2. Zed・Ghostty設定

```bash
./scripts/install.sh
```

既存のZed・Ghostty設定がある場合は、削除せず同じ場所へバックアップしてからシンボリックリンクを作ります。`~/.zshrc`にも読み込み設定を追記します。

Zedを起動後、コマンドパレットから`cli: install cli binary`を一度実行してください。

`install.sh`はZedに限ってmacOSのアクセント文字ポップアップを無効にし、英字の長押しをキーリピートに変更します。反映にはZedの完全終了と再起動が必要です。

GitHub CLIを初めて使うPCでは、現在行のPRを開く機能のために一度ログインします。

```bash
gh auth login
```

エディタ上で`Option + Command + P`を押すと、現在行に関連するGitHub PRをブラウザで開けます。

元のアクセント文字入力へ戻す場合は、次を実行します。

```bash
defaults delete dev.zed.Zed ApplePressAndHoldEnabled
```

### 設定変更をGitHubへ反映

`install.sh`の実行後は、ZedとGhosttyのユーザー設定がこのリポジトリへ直接リンクされます。設定を変更したら、次のコマンドだけでGitHubへ反映できます。

```bash
dev-sync
```

コミットメッセージを指定することもできます。

```bash
dev-sync "フォントサイズを変更"
```

`dev-sync`はGitHubの`main`をfast-forwardで取得し、秘密情報とJSON構文を検査したうえで、ZedとGhosttyの設定だけをコミットしてpushします。以前の`zed-sync`も互換コマンドとして利用できます。別の変更、未追跡ファイル、競合、`main`以外のブランチがある場合は何も公開せず停止します。

### 3. Railsプロジェクト

Railsプロジェクトのルートで実行します。

```bash
mkdir -p .zed
cp /path/to/rails-dev-dotfiles/templates/rails/.zed/settings.json .zed/settings.json
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
