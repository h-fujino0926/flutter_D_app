# 付箋タスク（仮）

PC のデスクトップに「付箋」のようにタスクを貼って管理できる、**チーム向けのリアルタイム共有タスク管理アプリ**です。
Flutter（Windows デスクトップ）＋ Supabase（無料プラン）で作っています。

- 設計の決定事項・権限の方針・ER 図 → [docs/design.md](docs/design.md)
- 実装プロンプト → [設計/ClaudeCode用_実装プロンプト.md](設計/ClaudeCode用_実装プロンプト.md)

---

## 1. 必要なもの

| もの | バージョン | 備考 |
|---|---|---|
| Flutter | **3.44.4**（stable） | チーム全員で同じバージョンにそろえる |
| Node.js | 18 以上 | Supabase CLI を動かすためだけに使う |
| Docker Desktop | 最新 | ローカルの Supabase（`supabase start`）に必要。WSL2 バックエンド |
| Windows の開発者モード | **ON（必須）** | OFF だと `Building with plugins requires symlink support` でビルドが止まる（設定 → システム → 開発者向け → 開発者モード） |
| Inno Setup 6 | 任意 | インストーラーを作る人だけ |

## 2. はじめてのセットアップ

```bash
flutter pub get
```

```bash
npm install
```

```bash
npx supabase start
```

`supabase start` の最後に表示される **API URL** と **Publishable key** を使って、`env.example.json` をコピーした `env.json` を作ります（`env.json` はコミットしません）。

```json
{
  "SUPABASE_URL": "http://127.0.0.1:54321",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
}
```

> ⚠️ アプリに入れてよいのは URL と publishable（anon）キーだけです。**service_role キーは絶対に入れないでください。**

## 3. 起動

```bash
flutter run -d windows --dart-define-from-file=env.json
```

VS Code の場合は「実行とデバッグ」から **付箋タスク（Windows）** を選べば同じ設定で起動します。

### 開発用のテストユーザー（ローカルのみ）

`supabase/seed.sql` で作られます。パスワードは全員 `password123` です。

| メール | 役割 |
|---|---|
| alice@example.com | チームA の作成者（leader） |
| bob@example.com | チームA の一般メンバー |
| carol@example.com | チームB の作成者（チームA とは無関係） |

ローカルで送られたメール（パスワード再設定など）は Mailpit（ http://127.0.0.1:54324 ）で見られます。
DB の中身は Supabase Studio（ http://127.0.0.1:54323 ）で見られます（**見るだけ。変更はマイグレーションで**）。

### モデル・Provider を変更したとき（コード生成）

`*.freezed.dart` / `*.g.dart` は自動生成ファイルです（手で編集しない）。`lib/core/models/models.dart` や `@riverpod` の付いたファイルを変更したら再生成してください。

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 4. DB の変更ルール

- **DB の変更は必ず `supabase/migrations/` に SQL ファイルを追加して行う**（ダッシュボードで直接いじらない）。
- 新しいファイルの作り方：

```bash
npx supabase migration new 変更内容の名前
```

- ローカルの DB を作り直す（マイグレーション＋seed を最初から流し直す）：

```bash
npx supabase db reset
```

- RLS のテスト（pgTAP）：

```bash
npx supabase test db
```

## 5. クラウド（本番）への反映

初回だけプロジェクトとつなぎます（プロジェクト参照IDはダッシュボードの URL に出ている英数字）。

```bash
npx supabase link --project-ref dglklmpcvyvinfoacyoz
```

> ⚠️ **初回のみ**：クラウドには以前ダッシュボードで作ったテーブル（`team` など）が残っています。
> マイグレーションと食い違うので、反映前に **クラウドの DB を初期化**してください（データはすべて消えます）。
>
> ```bash
> npx supabase db reset --linked
> ```

マイグレーションをクラウドへ反映：

```bash
npx supabase db push
```

## 6. Supabase 無料プランの注意

| 制約 | 対策・手順 |
|---|---|
| **1週間アクセスがないとプロジェクトが一時停止** | 大会前などは定期的にアクセスする。停止したらダッシュボードの「Restore project」で再開できる |
| 自動バックアップなし | スキーマは Git（マイグレーション）で管理。データは下のコマンドで手動バックアップ |
| 認証メールは1時間に数通まで | 開発中はダッシュボード → Authentication → Sign In / Providers → Email の「Confirm email」を OFF。本番運用では Resend / Brevo などの無料 SMTP を Authentication → Emails → SMTP Settings に設定する |
| DB 容量 500MB | 画像は保存しない（アイコンは頭文字＋色） |
| 有効なプロジェクトは2つまで | 開発はローカル（`supabase start`）、クラウドは本番用の1つだけ |

データの手動バックアップ（クラウド）：

```bash
npx supabase db dump --linked --data-only -f backup_data.sql
```

### クラウドのメール文面（確認コード方式）

デスクトップアプリなので、メール内のリンクではなく **6桁の確認コード** を送ります。
ローカルは `supabase/config.toml` と `supabase/templates/*.html` で設定済みです。クラウドではダッシュボードで次のように変更してください。

1. Authentication → Emails → **Reset Password** の本文を `supabase/templates/recovery.html` の内容に置き換える（`{{ .Token }}` が6桁コード）
2. 本番で「Confirm email」を ON にする場合は、**Confirm signup** の本文も `supabase/templates/confirmation.html` に置き換える

## 7. 配布（インストーラー版・zip 版）

```bash
flutter build windows --release --dart-define-from-file=env.json
```

- **インストーラー版**：[Inno Setup 6](https://jrsoftware.org/isinfo.php) で `installer/fusen_app.iss` をコンパイル → `build/installer/FusenTask-Setup.exe`
- **zip 版**：次のスクリプトで `build/installer/FusenTask-portable.zip` を作る

```bash
powershell -ExecutionPolicy Bypass -File tool/package_zip.ps1
```

> コード署名をしていないため、初回起動時に Windows SmartScreen の警告が出ます（「詳細情報」→「実行」）。
> 両方入れた場合、招待URL（`fusenapp://`）は「最後に起動した方」で開きます。

## 8. 機能と画面の動作確認（ローカル）

`npx supabase start` → アプリを起動し、seed のユーザーで確認します。リアルタイム同期は **アプリを2つ起動**（1つは `flutter run`、もう1つはビルド済みの exe）して、別のユーザーでログインすると確認できます。

| フェーズ | 確認すること |
|---|---|
| 2 認証 | 新規登録 → 自動でチーム作成画面へ／ログアウト → ログイン／「保持する」を外して再起動するとログイン画面／パスワード再設定（Mailpit にコードが届く） |
| 3 チーム | チーム作成で「メイン」ボードができる／チーム管理でボード追加・切替 |
| 4〜5 付箋 | 追加 → 空いている位置に出る／ドラッグで移動（もう1つのアプリで滑らかに動く）／詳細で編集・担当者変更／✓で完了 → 飛んでいく → 5秒以内なら「元に戻す」 |
| 6 復元・メッセージ | 削除 → 「完」→ゴミ箱から復元／一言メッセージを更新すると担当者に通知 |
| 7 前回復元 | 別のボードを開いてから再起動 → そのボードが開く／設定で表示名・色の変更 |
| 8 招待 | alice でチーム管理 →「招待を発行」→ carol で「招待で参加」に URL とパスコード（5回間違えると無効） |
| 9 メンバー | ロール変更（作成者は変更不可）／退出（作成者は退出不可） |
| 10 通知・レビュー | bob が完了 → alice に Windows 通知とベルの未読数／alice が「完」から承認・差し戻し → bob に通知 |
| 11 ミニウィンドウ | ×ボタン → 右端のミニウィンドウ（最前面）／右へフリックで完了／クリックでメインに戻り詳細が開く／タスクトレイのメニュー |
| 12 見た目・カレンダー | 締切24時間以内はオレンジ枠＋揺れる、期限切れは赤＋めくれ／カレンダーで付箋を別の日へドラッグ |

## 9. チーム開発のルール

- `main` に直接コミットしない。フェーズごとに `feature/phase-N-内容` のブランチを切って PR を出す。
- パッケージのバージョンは `pubspec.yaml` で完全固定。上げるときは1人がまとめて PR で上げる。
- コメントは日本語、クラス名・変数名・テーブル名・カラム名は英語（DB は snake_case）。
- PR を出す前に `flutter analyze`（警告ゼロ）と `flutter test`、DB を変えたら `npx supabase test db` を通す。
