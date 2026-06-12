# setup-mise

GitHub Actions の Ubuntu ランナーに [mise](https://mise.jdx.dev/) をセットアップするコンポジットアクションです。

## 使い方

```yaml
- uses: Coxless/mise-action@v1.0.0
```

## 入力パラメータ

| パラメータ | 説明 | デフォルト |
|---|---|---|
| `version` | インストールする mise のバージョン | 最新版 |
| `install` | セットアップ後に `mise install` を実行するか | `true` |
| `working_directory` | `mise install` を実行するディレクトリ | `.` |
| `cache` | mise バイナリとインストール済みツールをキャッシュするか | `true` |
| `log_level` | mise のログレベル (`trace`, `debug`, `info`, `warn`, `error`) | `info` |
| `config_file` | mise 設定ファイルのパス（キャッシュキーに使用、`working_directory` からの相対パス） | `.mise.toml` |
| `github_token` | レート制限回避のための GitHub トークン | `github.token` |

## 使用例

### 基本的な使い方

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: Coxless/mise-action@v1.0.0

  - run: node --version
```

### バージョン固定

```yaml
- uses: Coxless/mise-action@v1.0.0
  with:
    version: '2025.1.0'
```

### キャッシュ無効

```yaml
- uses: Coxless/mise-action@v1.0.0
  with:
    cache: 'false'
```

### `mise install` をスキップ

```yaml
- uses: Coxless/mise-action@v1.0.0
  with:
    install: 'false'
```

### サブディレクトリの設定ファイルを使用

```yaml
- uses: Coxless/mise-action@v1.0.0
  with:
    working_directory: backend
    config_file: .mise.toml
```

## 社内プロダクトへの組み込み

このアクションはリポジトリにコピーするか、Git サブモジュールとして追加して使うことができます。

### コピーして使う

アクションのファイル一式（`action.yml`・`run.sh`）を自リポジトリの任意のディレクトリにコピーします。

```
.github/actions/setup-mise/
├── action.yml
└── run.sh
```

ワークフローからはローカルパスで参照します。

```yaml
- uses: ./.github/actions/setup-mise
```

### Git サブモジュールとして使う

```bash
git submodule add <このリポジトリのURL> .github/actions/setup-mise
```

ワークフローで `actions/checkout` 実行時にサブモジュールも取得するよう設定します。

```yaml
- uses: actions/checkout@v4
  with:
    submodules: true

- uses: ./.github/actions/setup-mise
```

## キャッシュについて

`cache: 'true'`（デフォルト）の場合、mise バイナリとインストール済みツールの両方がキャッシュされます。

キャッシュキーは `mise-<OS>-<バージョン>-<設定ファイルのハッシュ>` の形式です。設定ファイルを変更すると自動的にキャッシュが再作成されます。

## 動作環境

Ubuntu ランナー（`ubuntu-latest` など）のみ対応しています。
