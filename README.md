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
| Windows の開発者モード | ON | Flutter のプラグインのビルドに必要（設定 → システム → 開発者向け → 開発者モード） |

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

## 7. チーム開発のルール

- `main` に直接コミットしない。フェーズごとに `feature/phase-N-内容` のブランチを切って PR を出す。
- パッケージのバージョンは `pubspec.yaml` で完全固定。上げるときは1人がまとめて PR で上げる。
- コメントは日本語、クラス名・変数名・テーブル名・カラム名は英語（DB は snake_case）。
- PR を出す前に `flutter analyze`（警告ゼロ）と `flutter test`、DB を変えたら `npx supabase test db` を通す。
