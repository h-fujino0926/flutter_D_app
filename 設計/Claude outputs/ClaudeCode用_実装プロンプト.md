# Claude Code 実装プロンプト：付箋風タスク管理ツール（仮）【Supabase版】

あなたはこのプロジェクトの実装担当エンジニアです。以下の仕様に従って、**Flutter（Windowsデスクトップ）＋ Supabase（無料プラン）**でアプリを実装してください。
同じフォルダ（またはリポジトリ内の `設計/`）にある設計書（21〜27番のExcel）とプロジェクト計画書も参照できますが、**設計書同士で矛盾している箇所は、このプロンプトの「確定事項」を優先**してください。設計書のシーケンス図に出てくる Firebase / Firestore / FCM / Cloud Functions は、すべて Supabase の機能に置き換えます（§11）。

---

## 0. 作業の進め方（最初に必ず守ること）

1. いきなり全部を書かず、まず以下を出力して私の確認を待ってください。
   - ディレクトリ構成案
   - DBのテーブル定義（ER図をMermaidで）とRLSポリシーの方針（本プロンプト §5 をベースに）
   - フェーズ0〜1で作るファイル一覧
2. 実装は §9 のフェーズ順に進め、**1フェーズ終わるごとに動作確認手順を書いて止まる**こと。
3. 仕様が曖昧な箇所は勝手に決めず、「仮決定した内容」と「理由」をコメントとチャットの両方に明記すること。
4. チーム開発（3人程度）なので、コードは読みやすさ優先。**コメントは日本語**、クラス名・変数名・テーブル名・カラム名は英語（snake_case）。
5. **DBの変更は必ずマイグレーションファイル（`supabase/migrations/*.sql`）で行う。** Supabase ダッシュボードで直接テーブルをいじらない（チームメンバー間でDBの状態がずれるのを防ぐため）。
6. 秘密情報はコミットしない。クライアントに置いてよいのは **Project URL と anon（publishable）キーだけ**。`service_role` キーはアプリに絶対に含めない。値は `--dart-define-from-file=env.json` で渡し、`env.json` は `.gitignore`、`env.example.json` をコミットする。

---

## 1. アプリの概要

### 1.1 何を作るか
PCのデスクトップ上に「付箋」のようにタスクを貼って管理できる、**チーム向けのリアルタイム共有タスク管理アプリ**。

### 1.2 解決したい課題
- チーム制作では複数人が別々のタスクを並行して進めるが、口頭や個人メモでは情報が分散し、抜け漏れや進捗の把握漏れが起きる。
- タスクを確認するたびに専用アプリを開くのが面倒で、確認頻度が下がる。

### 1.3 解決方法
- タスクを付箋としてボードに登録・配置し、担当者・期限・進捗をチーム内でリアルタイム共有する。
- 自分の担当タスクだけを**PC画面右端の常駐ミニウィンドウ（最前面表示）**に出し、別作業中でも目に入るようにする。

### 1.4 利用者と規模
- 想定ユーザー：学校のチーム開発、企業の小規模開発チーム
- 1チーム 5〜10人。1ユーザーは複数チームに所属できる。
- ロールは「チームリーダー（leader）」と「一般メンバー（member）」の2種類。

### 1.5 2つの利用モード
| モード | 画面 | 目的 |
|---|---|---|
| **管理モード** | メインウィンドウ（ボード画面） | チーム・ボード・付箋の作成／編集／割り当て／レビュー |
| **日常モード** | 画面右端の常駐ミニウィンドウ | 所属する全チームの「自分の担当タスク」だけを期限順に表示し、その場で完了操作できる |

---

## 2. 技術スタック（確定事項）

| 区分 | 採用技術 |
|---|---|
| クライアント | Flutter（**Windows デスクトップを主対象**。可能ならWebでも動く構成にする） |
| バックエンド | **Supabase 無料プラン**（PostgreSQL / Auth / Realtime） |
| Supabase クライアント | `supabase_flutter` |
| サーバー側ロジック | **PostgreSQL の関数（RPC）とトリガー**で実装。Edge Functions は原則使わない（必要になったら相談すること） |
| ローカル開発 | Supabase CLI（`supabase init` / `supabase start`、Docker 必須）、マイグレーションは `supabase/migrations/` |
| 状態管理 | Riverpod（`flutter_riverpod` + `riverpod_annotation`） |
| ルーティング | `go_router` |
| モデル | `freezed` + `json_serializable`（DBのsnake_caseと相互変換する） |
| 常駐ウィンドウ | `window_manager`（最前面・位置・サイズ制御）、`tray_manager`（タスクトレイ常駐） |
| OS通知 | `local_notifier`（Windowsトースト通知） |
| カレンダー | `table_calendar` |
| ディープリンク | `app_links`（カスタムURLスキーム） |
| ローカル保存 | `shared_preferences`（ログイン保持設定・前回のチーム/ボードのキャッシュ） |

---

## 3. Supabase 無料プランの制約と、このアプリでの対策

（2026年11月時点の公式料金ページの内容。実装前に https://supabase.com/pricing で最新値を確認すること）

| 制約 | 内容 | このアプリでの対策 |
|---|---|---|
| DB容量 | 500MB / プロジェクト | 画像は保存しない（アイコンは頭文字＋色）。ゴミ箱は30日で物理削除（任意機能） |
| Realtime 同時接続 | ピーク200接続 | 1ユーザー1接続にまとめる（チャンネルを開きすぎない。画面を離れたら `removeChannel`） |
| Realtime メッセージ | 月200万件 | ドラッグ中の位置送信は **100ms に1回まで**に間引く。DBへの書き込みはドロップ時の1回だけ |
| 一時停止 | **1週間アクセスがないとプロジェクトが停止** | 校内大会前などは定期的にアクセスする。停止したらダッシュボードから再開できることをREADMEに書く |
| バックアップ | 自動バックアップなし | スキーマはマイグレーションで Git 管理。データは `supabase db dump --data-only` を手動で取る手順をREADMEに書く |
| 認証メール | 標準のメール送信は1時間に数通程度に制限 | 開発中はダッシュボードで「Confirm email」をOFF。本番運用時は無料のSMTP（Resend / Brevo など）を設定する手順をREADMEに書く |
| プロジェクト数 | 有効なプロジェクトは2つまで | 開発用はローカル（`supabase start`）、クラウドは本番用1つだけ使う |

---

## 4. 機能一覧（全30機能）

優先度：**必須** = 校内大会までに必ず動かす／**推奨** = できれば入れる／**追加候補** = 最後に余裕があれば

### 4.1 付箋管理機能
| No | 機能 | 詳細仕様 | 優先度 |
|---|---|---|---|
| 1 | 付箋登録（タスク名） | タイトルを入力して付箋を新規作成。タイトルは必須・最大50文字。 | 必須 |
| 2 | 開始日・締切日 | 開始日と締切日を日付ピッカーで設定（どちらも任意）。開始日 > 締切日 はエラー（DBのCHECK制約でも防ぐ）。 | 必須 |
| 3 | 担当者設定 | チームの参加メンバー一覧から担当者を選択（複数選択可、未割り当ても可）。 | 必須 |
| 4 | 一覧表示 | ボード上に付箋を表示。右側パネルに「現在のチームの自分の担当タスク」を期限順で表示。 | 必須 |
| 5 | 移動・選択 | 付箋をドラッグ＆ドロップで任意の位置へ移動。クリックで詳細画面を開く。 | 必須 |
| 6 | 内容編集 | タイトル・詳細・開始日・締切日・担当者・優先度を編集。 | 必須 |
| 7 | 色・見た目変更 | 付箋の色（6色程度のプリセット）とサイズ（S/M/L）を変更。**期限が近い／超過した付箋は見た目で警告**（§6.3）。 | 推奨 |
| 8 | ステータス変更 | 未着手／進行中／完了 を切り替え。完了時は**付箋がめくれて飛んでいくアニメーション（0.3〜0.5秒）**を再生し、画面下部に「元に戻す」トーストを**5秒間**表示（押すと直前の状態に戻る）。 | 必須 |
| 9 | リアルタイム同期 | 付箋の追加・編集・移動・削除を、同じボードを開いている他メンバーへ**1秒未満**で反映。 | 必須 |
| 10 | 作成者・担当者表示 | 付箋上に作成者と担当者をアイコン（頭文字＋ユーザーごとの色の丸アイコン）で表示。 | 必須 |
| 11 | カレンダー表示 | ボード表示 ⇔ カレンダー表示を切り替え。日付ごとに締切のある付箋を表示。カレンダー上で付箋をドラッグして別の日に落とすと締切日が変わる。 | 推奨 |
| 12 | ゴミ箱・完了ログ | 削除した付箋（ゴミ箱）と完了した付箋（完了ログ）を一覧表示し、ボードへ復元できる。削除は論理削除（`deleted_at` を入れるだけ）。 | 必須 |
| 13 | 一言メッセージ | 付箋ごとに**テキスト枠を1つ**持ち、上書き保存で最新の指示・連絡を共有（常に最新1件）。更新時は担当者へ通知。最大100文字。 | 必須 |

### 4.2 ユーザー機能
| No | 機能 | 詳細仕様 | 優先度 |
|---|---|---|---|
| 14 | 新規登録 | メールアドレス・パスワード・表示名で登録（Supabase Auth）。パスワードは8文字以上、確認用と一致チェック。 | 必須 |
| 15 | ログイン・ログアウト | メール／パスワードでログイン。設定メニューからログアウト。 | 必須 |
| 16 | ログイン状態保持 | 「この端末でログイン状態を保持する」を選ぶと、アプリ再起動後も自動ログイン。保持しない場合は起動時にログイン画面へ。 | 必須 |
| 17 | プロフィール編集 | 表示名・アイコン色を確認・変更。 | 推奨 |
| 18 | 前回チーム・ボード復元 | 最後に開いていたチーム・ボードを保存し、次回ログイン時にそのボードを直接開く。 | 必須 |
| — | パスワード再設定 | 「パスワードをお忘れですか？」→ メールに届く**6桁の確認コード**をアプリで入力 → 新しいパスワードを設定（デスクトップアプリなのでメール内リンクではなくコード方式）。 | 推奨 |

### 4.3 チーム機能
| No | 機能 | 詳細仕様 | 優先度 |
|---|---|---|---|
| 19 | チーム作成 | チーム名（必須）・説明（任意）を入力して作成。作成者は自動でリーダーになり、初期ボード「メイン」も自動作成。 | 必須 |
| 20 | チーム一覧 | 参加中のチームを一覧表示し、切り替える。 | 必須 |
| 21 | 招待コード発行 | リーダーが招待を発行すると、**重複しない6桁の英数字パスコード**と招待URLを自動生成。 | 必須 |
| 22 | 招待の有効期限 | 招待URL・パスコードは**発行から72時間有効**。期限切れ・無効化済みの場合は参加を拒否。 | 必須 |
| 23 | 招待参加 | 招待URLを開く（またはアプリにURLを貼り付ける）→ 6桁パスコード入力 → チームに参加。 | 必須 |
| 24 | メンバー一覧・退出 | 参加メンバーを一覧表示。自分でチームを退出できる（最後のリーダーは退出不可）。 | 必須 |
| 25 | 役割・権限設定 | リーダーがメンバーのロールを leader／member に変更できる（§4.6 権限表）。 | 推奨 |
| 26 | ボード作成 | チーム内に用途別のボード（例：「UI班」「API班」）を複数作成できる。 | 必須 |

### 4.4 通知・レビュー機能
| No | 機能 | 詳細仕様 | 優先度 |
|---|---|---|---|
| 27 | 完了通知 | メンバーがタスクを完了すると、**チームリーダー全員とタスク作成者**へ通知（本人は除く）。文言例：「〇〇さんがタスク【〇〇】を完了しました」 | 必須 |
| 28 | コメント付き差し戻し | リーダーは完了済みタスクを確認し、①承認する ②一言メッセージを添えて差し戻す を選べる。差し戻すとステータスは「進行中」に戻り、担当者へ通知。 | 必須 |

### 4.5 デスクトップ・外部連携
| No | 機能 | 詳細仕様 | 優先度 |
|---|---|---|---|
| 29 | 常駐ミニウィンドウ | 画面右端に、**所属する全チームの自分の担当付箋（未完了のみ）**を期限が近い順に常時最前面表示。付箋を右へフリック（弾く）またはチェックで完了。クリックで管理モードの該当付箋を開く。 | 必須 |
| 30 | Googleカレンダー連携 | ユーザーが許可したGoogleカレンダーへ、締切付きタスクを登録・更新・削除。 | 追加候補 |

### 4.6 ロールと権限（仮決定・変更可）

| 操作 | leader | member |
|---|---|---|
| 付箋の作成・編集・移動・ステータス変更 | ○ | ○ |
| 付箋の削除・復元 | ○ | 自分が作成した付箋のみ |
| 担当者の割り当て | ○ | ○ |
| 完了タスクの承認・差し戻し | ○ | × |
| ボード作成 | ○ | × |
| 招待の発行・無効化 | ○ | × |
| メンバーのロール変更 | ○ | × |
| チーム情報の編集・削除 | 作成者（owner）のみ | × |
| チーム退出 | ○（最後のリーダー以外） | ○ |

権限チェックは **UI での非表示** と **RLS（行レベルセキュリティ）／RPC内のチェック** の両方で行うこと。UIだけで済ませない。

---

## 5. データベース設計（Supabase / PostgreSQL）

設計書のテーブル定義書（user / team / member / team_invite / task / task_member / notifications / user_setting / board / board_column）を、ほぼそのまま PostgreSQL に落とします。設計書の誤字（`joinde_at`, `invitaion_id`, `failded_attempts`, `varcher` など）は修正した名前で作成してください。

### 5.1 共通ルール
- 主キー：ユーザーは Supabase Auth の `auth.users.id`（uuid）を使う。それ以外のテーブルは `bigint generated always as identity`。
- 日時はすべて `timestamptz`。`created_at default now()`、`updated_at` はトリガーで自動更新。
- 論理削除は `deleted_at`／`left_at`／`revoked_at` に日時を入れる方式（設計書どおり）。
- enum は PostgreSQL の `create type ... as enum` で作る。
- すべてのテーブルで **RLS を有効化**（`alter table ... enable row level security`）。RLSなしのテーブルを作らない。

### 5.2 enum
```sql
create type team_role       as enum ('leader', 'member');
create type task_status     as enum ('todo', 'in_progress', 'done');
create type task_priority   as enum ('high', 'medium', 'low');
create type task_size       as enum ('S', 'M', 'L');
create type notification_type as enum
  ('task_completed', 'task_returned', 'task_approved', 'message_updated', 'task_assigned');
```

### 5.3 テーブル

**profiles**（設計書の user。認証情報は auth.users が持つので、パスワードはここに置かない）
| カラム | 型 | 制約・初期値 | 備考 |
|---|---|---|---|
| id | uuid | PK, FK → auth.users(id) on delete cascade | |
| display_name | text | not null, 1〜20文字 | |
| email | text | not null, unique | 表示用コピー |
| icon_color | text | not null default '#F4A261' | |
| last_login_at | timestamptz | null | |
| created_at / updated_at | timestamptz | not null default now() | |
| deleted_at | timestamptz | null | |

→ `auth.users` への INSERT トリガー（`handle_new_user`）で自動作成。表示名は signUp の `data: {display_name}` から取る。

**user_settings**（設計書の user_setting）
| カラム | 型 | 制約・初期値 | 備考 |
|---|---|---|---|
| user_id | uuid | PK, FK → profiles | |
| last_team_id | bigint | null, FK → teams on delete set null | 機能18 |
| last_board_id | bigint | null, FK → boards on delete set null | 機能18 |
| mini_window_enabled | boolean | not null default true | |
| skip_keep_login_prompt | boolean | not null default false | P0-05「次回から表示しない」 |
| google_calendar_linked | boolean | not null default false | |
| updated_at | timestamptz | | |

※「ログイン状態を保持するか」は端末ごとの設定なので DB ではなく `shared_preferences` に保存。

**teams**
| カラム | 型 | 制約・初期値 |
|---|---|---|
| team_id | bigint identity | PK |
| name | text | not null, 1〜30文字 |
| description | text | null |
| owner_user_id | uuid | not null, FK → profiles |
| created_at / updated_at / deleted_at | timestamptz | |

**team_members**（設計書の member）
| カラム | 型 | 制約・初期値 |
|---|---|---|
| team_member_id | bigint identity | PK |
| team_id | bigint | not null, FK → teams |
| user_id | uuid | not null, FK → profiles |
| role | team_role | not null default 'member' |
| joined_at | timestamptz | not null default now() |
| left_at | timestamptz | null（退出時に設定） |
| | | unique(team_id, user_id) |

**team_invites**（設計書の team_invite）
| カラム | 型 | 制約・初期値 | 備考 |
|---|---|---|---|
| invitation_id | bigint identity | PK | |
| team_id | bigint | not null, FK | |
| token | text | not null, unique | URL用ランダム文字列（`gen_random_bytes` で32文字程度） |
| passcode_hash | text | not null | 6桁パスコードのハッシュ（平文保存しない） |
| created_by | uuid | not null, FK → profiles | |
| expires_at | timestamptz | not null | 発行 + 72時間 |
| max_uses | int | not null default 0 | 0 = 無制限 |
| used_count | int | not null default 0 | |
| failed_attempts | int | not null default 0 | 5回で自動無効化 |
| revoked_at | timestamptz | null | |
| created_at | timestamptz | not null default now() | 設計書で `created_by` と重複していた列名を修正 |

→ **クライアントからの SELECT/INSERT/UPDATE はすべて禁止**（RLSでポリシーを作らない）。操作は §5.5 の RPC からのみ。

**boards**
| カラム | 型 | 制約・初期値 |
|---|---|---|
| board_id | bigint identity | PK |
| team_id | bigint | not null, FK |
| name | text | not null, 1〜30文字 |
| created_by | uuid | not null |
| created_at / updated_at | timestamptz | |

**board_columns**（設計書の board_column。ボード作成時にトリガーで3列を自動作成）
| カラム | 型 | 制約・初期値 |
|---|---|---|
| column_id | bigint identity | PK |
| board_id | bigint | not null, FK on delete cascade |
| status | task_status | not null |
| name | text | not null（'未着手' / '進行中' / '完了'） |
| sort_order | int | not null |
| | | unique(board_id, status) |

**tasks**（設計書の task に、ドメインモデル図・機能要件にある列を追加）
| カラム | 型 | 制約・初期値 | 備考 |
|---|---|---|---|
| task_id | bigint identity | PK | |
| team_id | bigint | not null, FK | RLS判定用 |
| board_id | bigint | not null, FK | 追加 |
| title | text | not null, 1〜50文字 | |
| description | text | null | |
| start_date | date | null | 追加（機能2） |
| due_date | date | null | 設計書の fixed_date |
| priority | task_priority | not null default 'medium' | |
| status | task_status | not null default 'todo' | |
| pos_x / pos_y | double precision | not null default 0 | 追加。列内の相対座標 |
| color | text | not null default '#FFF59D' | 追加（機能7） |
| size | task_size | not null default 'M' | 追加（機能7） |
| latest_comment | text | null, 最大100文字 | 追加（機能13 一言メッセージ） |
| latest_comment_by | uuid | null | |
| latest_comment_at | timestamptz | null | |
| created_by | uuid | not null, FK → profiles | |
| completed_at | timestamptz | null | 設計書の complete_at |
| completed_by | uuid | null | |
| reviewed_at | timestamptz | null | リーダー承認日時 |
| deleted_at | timestamptz | null | ゴミ箱 |
| created_at / updated_at | timestamptz | | 設計書で updated_at の論理名が「削除日」になっていたのを修正 |
| | | check (start_date is null or due_date is null or start_date <= due_date) | |

**task_members**（設計書の task_member：担当者の多対多）
| カラム | 型 | 制約・初期値 |
|---|---|---|
| task_member_id | bigint identity | PK |
| task_id | bigint | not null, FK on delete cascade |
| user_id | uuid | not null, FK → profiles |
| assigned_at | timestamptz | not null default now() |
| | | unique(task_id, user_id) |

※設計書では team_member_id を参照していたが、RLSとクエリを単純にするため user_id を参照する。

**task_status_history**（ドメインモデル図の TaskStatusHistory）
| カラム | 型 | 備考 |
|---|---|---|
| history_id | bigint identity | PK |
| task_id | bigint | FK on delete cascade |
| user_id | uuid | 操作した人 |
| from_status / to_status | task_status | |
| comment | text | 差し戻し時のメッセージ |
| created_at | timestamptz | |

→ tasks の status 変更時にトリガーで自動記録。

**notifications**
| カラム | 型 | 制約・初期値 |
|---|---|---|
| notification_id | bigint identity | PK |
| recipient_user_id | uuid | not null, FK |
| actor_user_id | uuid | null |
| team_id | bigint | null |
| task_id | bigint | null |
| type | notification_type | not null |
| message | varchar(255) | not null |
| is_read | boolean | not null default false |
| created_at | timestamptz | not null default now() |

→ 作成はトリガー（security definer）のみ。クライアントは自分宛ての SELECT と `is_read` の UPDATE だけ可。

### 5.4 RLS（行レベルセキュリティ）
- まず `security definer` のヘルパー関数を作る（RLS内でteam_membersを参照すると無限再帰になるため）。`set search_path = ''` を必ず付ける。
  - `is_team_member(p_team_id bigint) returns boolean` … 自分が `left_at is null` で所属しているか
  - `is_team_leader(p_team_id bigint) returns boolean`
- ポリシー内では `auth.uid()` を `(select auth.uid())` と書く（パフォーマンス対策）。
- 主なポリシー：
  | テーブル | SELECT | INSERT | UPDATE | DELETE |
  |---|---|---|---|---|
  | profiles | 自分＋同じチームのメンバー | トリガーのみ | 自分のみ | 不可 |
  | user_settings | 自分のみ | 自分のみ | 自分のみ | 不可 |
  | teams | メンバー | RPC `create_team` のみ | owner のみ | 不可（論理削除） |
  | team_members | 同じチームのメンバー | RPCのみ | RPCのみ | 不可 |
  | team_invites | 不可 | 不可 | 不可 | 不可（RPCのみ） |
  | boards / board_columns | メンバー | leader | leader | 不可 |
  | tasks | メンバー | メンバー（created_by = 自分） | メンバー（ただし status の done→承認系はRPC経由） | 不可（論理削除） |
  | task_members | メンバー | メンバー | — | メンバー |
  | task_status_history | メンバー | トリガーのみ | 不可 | 不可 |
  | notifications | 自分宛てのみ | トリガーのみ | 自分宛ての is_read のみ | 不可 |
- **RLSのテストを pgTAP で書き、`supabase test db` で実行**すること（他チームのデータが見えない、member が leader 操作をできない、招待テーブルが読めない、を最低限確認）。

### 5.5 RPC（`supabase.rpc()` で呼ぶ PostgreSQL 関数）
複数テーブルをまとめて更新する処理や、権限チェックが必要な処理は RPC にします。すべて `security definer`・`set search_path = ''`、関数の最初で `auth.uid()` と権限を確認すること。

| 関数 | 処理 |
|---|---|
| `create_team(p_name, p_description)` | teams 作成 → 自分を leader で team_members に追加 → 初期ボード「メイン」作成（board_columns はトリガー）→ team_id を返す |
| `create_invite(p_team_id, p_max_uses default 0)` | leader 確認 → 有効な招待と重複しない6桁パスコード生成 → ハッシュ化して保存 → `{token, passcode, expires_at}` を返す（**平文パスコードを返すのはこの1回だけ**） |
| `revoke_invite(p_invitation_id)` | leader 確認 → revoked_at 設定 |
| `join_team(p_token, p_passcode)` | §7.7 の判定順でチェック → team_members に追加 → team_id を返す。エラーは `raise exception` に識別しやすいコード（`INVITE_NOT_FOUND`, `INVITE_EXPIRED`, `INVITE_LIMIT`, `WRONG_PASSCODE`）を入れ、Flutter側で日本語メッセージに変換 |
| `leave_team(p_team_id)` | 最後のleaderなら拒否 → left_at 設定 |
| `change_member_role(p_team_id, p_user_id, p_role)` | leader 確認 → 最後のleaderを member にする変更は拒否 |
| `complete_task(p_task_id)` | status=done, completed_at, completed_by を設定（履歴と通知はトリガー） |
| `undo_complete(p_task_id, p_prev_status)` | 完了から**10秒以内**かつ自分が完了させた場合だけ元に戻す |
| `review_task(p_task_id, p_approve boolean, p_comment text)` | leader 確認。承認なら reviewed_at 設定、差し戻しなら comment 必須で latest_comment 上書き＋status=in_progress＋completed_at クリア |
| `get_my_tasks()` | 所属する全チームの「自分が担当・未完了・未削除」のタスクを、チーム名付きで due_date 昇順（nullは最後）で返す（ミニウィンドウ用） |

### 5.6 トリガー
| トリガー | 内容 |
|---|---|
| `on_auth_user_created`（auth.users AFTER INSERT） | profiles と user_settings を作成 |
| `set_updated_at`（各テーブル BEFORE UPDATE） | updated_at = now() |
| `on_board_created`（boards AFTER INSERT） | board_columns に3列作成 |
| `on_task_status_changed`（tasks AFTER UPDATE OF status） | task_status_history に記録。done になったら leader 全員＋作成者へ `task_completed` 通知（操作した本人は除く） |
| `on_task_comment_changed`（tasks AFTER UPDATE OF latest_comment） | 担当者＋作成者へ `message_updated` 通知（本人除く） |
| `on_task_member_added`（task_members AFTER INSERT） | 担当者へ `task_assigned` 通知（自分で自分を割り当てた場合は除く） |
| `review_task` 内 | `task_approved` / `task_returned` 通知を作成 |

### 5.7 Realtime の設定
- `alter publication supabase_realtime add table tasks, task_members, notifications, team_members, boards;`
- RLS が有効なテーブルの変更は、**その行を SELECT できるユーザーにだけ**配信される（他チームには届かない）ことを利用する。

---

## 6. 画面仕様

### 6.1 画面一覧
設計書の画面IDを踏襲。※印は設計書に未記載のため仮で追加したもの。

| 画面ID | 画面名 | 概要 |
|---|---|---|
| P0-01 | ログイン | メール・パスワード入力、ログインボタン、「パスワードをお忘れですか？」、「新規登録はこちら」 |
| P0-02 | 新規登録 | メール・パスワード・パスワード（確認）・表示名、登録ボタン、ログイン画面へ戻る |
| P0-03 | パスコード入力 | 6つの入力枠。1文字入力ごとに次の枠へ自動フォーカス、貼り付けで6枠に分配。6桁そろうと参加ボタンが有効 |
| P0-04 | パスワード再設定 | ①メール入力 → ②「確認コードを送信しました」＋6桁コード入力 → ③新しいパスワード入力 → ログイン画面へ |
| P0-05 | ログイン状態保持設定 | 「この端末でログイン状態を保持する」／「保持しない」のラジオ、「次回から表示しない」チェック、設定を保存 |
| P1-01 | メイン（ボード） | 下記 6.2 |
| P1-02 | 検索 | タイトル・担当者・ステータス・優先度で付箋を絞り込み |
| P1-03 | 付箋詳細 | 全項目の表示・編集、一言メッセージ欄、ステータス変更、（leaderのみ）承認／差し戻し、削除、ステータス履歴 |
| P1-04 | 付箋作成 | ダイアログ。タイトル・詳細・開始日・締切日・担当者・優先度、保存／キャンセル |
| P1-05 ※ | カレンダー | 月表示。日付セルに締切の付箋を表示し、D&Dで締切変更 |
| P1-06 | 通知一覧 | 通知を新しい順に表示、未読は強調、クリックで該当付箋へ（既読にする） |
| P1-07 ※ | ゴミ箱・完了ログ | タブ切替で削除済み／完了済みを一覧、復元ボタン |
| P1-08 ※ | チーム管理 | チーム作成、チーム一覧／切替、ボード作成、メンバー一覧、ロール変更、招待発行（URL・パスコード・有効期限を表示しコピーボタン）、退出 |
| P1-09 | 設定メニュー | プロフィール編集、ログイン保持設定、ミニウィンドウON/OFF、Googleカレンダー連携、ログアウト |
| P2-01 ※ | 常駐ミニウィンドウ | 下記 6.4 |

### 6.2 P1-01 メイン（ボード）画面のレイアウト
```
┌──────────────────────────────────────────────┐
│ ⚙設定   📅カレンダー切替   [チーム▼][ボード▼]   🔍  🔔(未読数)  👤 │ ← ヘッダー
├───────────────────────────────┬──────────────┤
│  未着手        │  進行中        │  完了          │ [＋追加] [完了ログ] │
│ ┌────┐       │ ┌────┐       │ ┌────┐       │──────────────│
│ │付箋│       │ │付箋│       │ │付箋│       │ 現在のチームの   │
│ └────┘       │ └────┘       │ └────┘       │ マイタスク      │
│   ＋付箋を追加 │  ＋付箋を追加  │  ＋付箋を追加  │ （期限が近い順） │
└───────────────────────────────┴──────────────┘
```
- ボード領域は board_columns の3列（未着手／進行中／完了）。**列の中では付箋を自由な位置に置ける**（pos_x/pos_y を保存）。
- 付箋を別の列へドラッグすると、ステータスもその列のものに変わる（完了列へ落とした場合は完了アニメーションと通知も発生）。
- 付箋カードの表示内容：タイトル、締切日、担当者アイコン、作成者アイコン（小）、優先度バッジ、一言メッセージがあれば吹き出しアイコン。
- 右パネル：現在のチームの自分の担当タスクを締切が近い順にリスト表示。
- 「完了ログ」ボタン → P1-07 へ。

### 6.3 付箋の見た目ルール
| 状態 | 見た目 |
|---|---|
| 通常 | 選択した色の付箋。ほんの少しランダムな傾き（±2°、task_id から決めて毎回同じ角度にする）と影で付箋らしさを出す |
| 締切まで24時間以内 | 枠をオレンジ、角に「まもなく」ラベル、軽く揺れるアニメーション（1回だけ） |
| 締切超過 | 背景を赤系、端がめくれたような形状、「期限切れ」ラベル |
| 差し戻し中 | 「差し戻し」ラベルと一言メッセージを強調表示 |
| ドラッグ中 | 少し拡大＋影を濃く |
| 他の人がドラッグ中 | その人のアイコンを付箋の横に小さく表示 |

### 6.4 常駐ミニウィンドウ（日常モード）
- サイズ：幅 280px 程度、高さは画面の高さに合わせる。画面右端に寄せて**常に最前面**。
- 枠なしウィンドウ、半透明背景。折りたたみ（細いタブだけ残す）ボタンあり。
- 表示内容：RPC `get_my_tasks()` の結果。チーム名を小さく表示。
- 操作：
  - 付箋を右へフリック、またはチェックで完了 → めくれて飛ぶアニメーション → 5秒間 Undo 表示
  - クリックでメインウィンドウを前面に出し、該当付箋の詳細を開く
- メインウィンドウを閉じてもミニウィンドウとタスクトレイは残る。トレイのメニューから「メインを開く」「ミニウィンドウ表示切替」「終了」。
- 設定でON/OFF可能。

---

## 7. 主要な処理フロー

### 7.1 起動・ログイン
1. 起動 → `Supabase.initialize()`（セッションは supabase_flutter が自動で端末に保存する）。
2. `shared_preferences` の `keepLoggedIn` が false なら、`auth.signOut(scope: SignOutScope.local)` してP0-01へ。true でセッションが有効ならそのまま自動ログイン。
3. ログイン成功 → `profiles.last_login_at` 更新 → `user_settings` の `last_team_id` / `last_board_id` を読み、そのボードを開く。
4. 前回チームがない（初回など）→「チームを作成」or「招待で参加」を選ぶ画面へ。
5. `skip_keep_login_prompt` が false のときだけ、ログイン直後に P0-05 を表示。
6. `onAuthStateChange` を Riverpod で監視し、セッション切れ時はログイン画面へ戻す。

### 7.2 付箋の作成
1. 「＋追加」→ P1-04 で入力 → 保存。
2. tasks に INSERT（`status: todo`、作成した列の空いている位置に pos_x/pos_y）→ 担当者を task_members に INSERT。
3. Realtime で全員の画面に即表示。担当者には `task_assigned` 通知（トリガー）。

### 7.3 付箋の移動とリアルタイム同期（非機能要件：1秒未満・カクつかない）
ボードを開いたら、`board:{board_id}` という **1つの Realtime チャンネル**に以下をまとめて登録する。
- `postgres_changes`：tasks（filter: `board_id=eq.{id}`）の INSERT/UPDATE → ボードの状態を更新
- `broadcast`：イベント名 `drag`（ドラッグ中の位置共有。DBは通らない）
- `presence`：今このボードを見ているメンバー（ヘッダーにアイコン表示）

移動の流れ：
1. ドラッグ中は**ローカルの状態だけ**を更新して即座に描画（楽観的更新）。
2. ドラッグ中は `broadcast`（`{task_id, x, y, user_id}`）を **100ms に1回まで**送信（throttle）。DBには書かない。
3. 他メンバー側は broadcast を受け取ったら、その付箋を新しい位置へ**アニメーションで滑らかに**移動。
4. ドロップ時に tasks を1回だけ UPDATE（pos_x, pos_y, 列が変わったなら status）。→ postgres_changes で全員の状態が確定値に揃う。
5. 自分がドラッグ中の付箋には、他人からの位置更新を適用しない。競合は「最後に書き込んだ人が勝つ」。
6. 画面を離れるときは `supabase.removeChannel()` で必ず購読解除（無料プランの同時接続数対策）。
7. 再接続時（ネットワーク復帰）は、ボードの全タスクを SELECT し直して状態を合わせる。

### 7.4 タスク完了と通知
1. 完了操作 → 0.3〜0.5秒のめくれアニメーション → RPC `complete_task`。
2. 画面下部に「元に戻す」トーストを5秒表示。押されたら RPC `undo_complete`。
3. DBトリガーが task_status_history に記録し、leader 全員と作成者へ notifications を INSERT。
4. 各ユーザーのアプリは起動中ずっと `notifications`（filter: `recipient_user_id=eq.{自分のuid}`）を購読しておき、新着を受け取ったら `local_notifier` でWindows通知＋ヘッダーのベルの未読数を更新。
5. アプリ起動時は、未読の通知を SELECT して未読数を表示（起動していない間に来た通知の取りこぼし対策）。

### 7.5 レビュー（承認・差し戻し）
1. leader が完了タスクの詳細を開く →「承認」または「差し戻し」。
2. RPC `review_task` を呼ぶ。
3. 承認：`reviewed_at` 設定 → 担当者へ `task_approved` 通知。
4. 差し戻し：一言メッセージ入力必須 → `latest_comment` 上書き、`status: in_progress`、`completed_at` クリア、履歴にコメント付きで記録 → 担当者へ `task_returned` 通知。

### 7.6 一言メッセージの上書き
1. 付箋詳細のメッセージ枠を書き換えて「更新」→ tasks の latest_comment / latest_comment_by / latest_comment_at を UPDATE。
2. Realtime で全員の画面の付箋に即反映。
3. トリガーが担当者（と作成者、本人除く）へ `message_updated` 通知。

### 7.7 招待の発行と参加
**発行（leader）**
1. P1-08 で「招待を発行」→ RPC `create_invite(team_id)`。
2. 関数内：leader 確認 → 大文字英字＋数字（紛らわしい `0 O 1 I` は除外）で6桁生成 → 有効な招待と重複しないか確認（重複チェックのため `passcode_hash` は `extensions.digest(passcode, 'sha256')` の16進文字列で保存）→ token を `encode(extensions.gen_random_bytes(24), 'hex')` で生成 → `expires_at = now() + interval '72 hours'`。
3. 画面に「招待URL（`fusenapp://join?token=xxxx`）」「パスコード」「有効期限」を表示し、それぞれコピーボタン。**パスコードはこの画面を閉じると二度と表示できない**旨を表示。

**参加（招待されたユーザー）**
1. 招待URLを開く、またはアプリの「招待で参加」にURLを貼り付ける。
2. 未ログインならログイン／新規登録を先に行い、終わったら参加フローに戻る（token を一時保存しておく）。
3. P0-03 で6桁を入力 →「参加」→ RPC `join_team(token, passcode)`。
4. 関数内の判定順：
   - token が存在しない／`revoked_at` あり → `INVITE_NOT_FOUND`「この招待は無効です」
   - `expires_at` を過ぎている → `INVITE_EXPIRED`「招待コードの有効期限（3日間）が切れています」
   - `max_uses > 0` かつ `used_count >= max_uses` → `INVITE_LIMIT`「この招待は使用上限に達しています」
   - パスコード不一致 → `failed_attempts + 1`（**この更新は例外を投げる前に確定させる**）、`WRONG_PASSCODE`「パスコードが正しくありません」。5回目で `revoked_at` を設定
   - すでにメンバー → そのまま team_id を返す（退出済みなら left_at を null に戻して再参加）
   - 成功 → team_members に追加（role: member）、`used_count + 1` → 対象チームのボードへ自動遷移
5. Windows でのカスタムURLスキーム登録は `app_links` のドキュメントに従う。うまくいかない場合でも「URL貼り付け」で必ず参加できるようにする。

### 7.8 ゴミ箱と復元
- 削除：`deleted_at` を設定（物理削除しない）。ボードから消え、P1-07 のゴミ箱タブへ。
- 復元：`deleted_at` を null に戻す。元の座標に他の付箋があれば少しずらして配置。
- 完了ログ：`status = done` の付箋一覧。復元すると `status: todo` に戻る。
- （任意）30日経過したゴミ箱データを `pg_cron` で物理削除（DB容量対策）。

### 7.9 パスワード再設定（デスクトップ向けコード方式）
1. P0-04 でメール入力 → `auth.resetPasswordForEmail(email)`。
2. Supabase ダッシュボードの「Reset Password」メールテンプレートを、リンクではなく `{{ .Token }}`（6桁コード）を表示する文面に変更しておく（手順をREADMEに書く）。
3. コード入力 → `auth.verifyOTP(type: OtpType.recovery, email, token)` → `auth.updateUser(UserAttributes(password: 新パスワード))`。

---

## 8. 非機能要件

| No | 項目 | 基準 | 実装上の対応 |
|---|---|---|---|
| 1 | 画面の同期 | 付箋の追加・移動などが他メンバーへ1秒未満で反映 | Realtime（postgres_changes＋broadcast）、楽観的更新 |
| 2 | 画面の動き | D&D中にフレームレートが落ちない（開発用ノートPCで60fps目安） | 付箋ごとに `RepaintBoundary`、ドラッグ中は該当付箋だけ再描画、送信は throttle |
| 3 | 同時接続 | 1ボードを5人で同時操作しても重くならない | ボード単位のチャンネル1本、必要なときだけ購読 |
| 4 | セキュリティ | ログインしたユーザーのみ利用可 | Supabase Auth ＋ 全テーブルRLS（未ログインの anon ロールには何も許可しない） |
| 5 | セキュリティ | 招待コードを持つユーザーのみ参加可 | 招待の検証は security definer の RPC のみ。team_invites はクライアントから読めない |
| 6 | データの永続化 | 付箋の変更は即DB保存し、再読み込みしてもリセットされない | 変更ごとに即 INSERT/UPDATE（ドラッグはドロップ時） |
| 7 | 利便性 | 前回のチーム・ボードを記憶し再ログイン時の手間を減らす | `user_settings.last_team_id / last_board_id` |
| — | パスワード | 平文保存しない | Supabase Auth に任せる（自前のパスワード列は作らない） |
| — | エラー処理 | 通信エラー時もアプリが落ちない | `PostgrestException` / `AuthException` を捕まえて日本語メッセージに変換し SnackBar 表示 |
| — | 無料プラン | §3 の制約内に収まる | §3 の対策をすべて実施 |

---

## 9. 実装フェーズ（この順番で進める）

プロジェクト計画のガントチャート順をベースに、ログインとテーブルがないとRLSが書けないため、DBと認証を前倒ししています。

| フェーズ | 内容 | 対応機能No |
|---|---|---|
| 0 | Flutterプロジェクト作成、`supabase init`、ディレクトリ構成、env 設定、ルーティング、テーマ | — |
| 1 | **全テーブル・enum・トリガー・RLS のマイグレーション作成**、pgTAPでRLSテスト | （設計書ガントの「0 テーブル作成」） |
| 2 | 新規登録・ログイン・ログアウト・ログイン保持・パスワード再設定 | 14, 15, 16 |
| 3 | チーム作成・チーム一覧・ボード作成（招待はまだ） | 19, 20, 26 |
| 4 | 付箋の登録・開始日/締切日・担当者・一覧表示 | 1, 2, 3, 4 |
| 5 | 付箋の移動（D&D）・詳細・編集・ステータス変更・完了アニメ＋Undo・リアルタイム同期 | 5, 6, 8, 9 |
| 6 | ゴミ箱・完了ログ・復元、一言メッセージ、作成者・担当者アイコン | 10, 12, 13 |
| 7 | 前回チーム・ボード復元、プロフィール編集 | 17, 18 |
| 8 | 招待コード発行・有効期限・招待参加（RPC） | 21, 22, 23 |
| 9 | メンバー一覧・退出・ロール変更 | 24, 25 |
| 10 | 完了通知・承認／差し戻し・通知一覧 | 27, 28 |
| 11 | 常駐ミニウィンドウ（最前面・タスクトレイ） | 29 |
| 12 | 付箋の色・サイズ・期限警告表示、カレンダー表示と期限変更 | 7, 11 |
| 13（任意） | Googleカレンダー連携（Supabase Auth の Google プロバイダで calendar スコープを取得する方式を検討し、着手前に相談） | 30 |

各フェーズの終わりに：
- `flutter analyze` で警告ゼロ
- そのフェーズのユニットテスト／ウィジェットテスト（DBが絡むものは `supabase test db`）
- ローカルSupabase（`supabase start`）での動作確認手順
- クラウドへの反映コマンド（`supabase db push`）
を出してください。

---

## 10. ディレクトリ構成（目安）

```
lib/
  main.dart
  app/            # ルーティング、テーマ、起動処理、Supabase初期化
  core/           # 定数、エラー変換、ユーティリティ（throttle 等）
  features/
    auth/         # data（repository）/ domain（model）/ presentation（画面・provider）
    team/
    board/
    task/         # 付箋（作成・編集・D&D・アニメーション）
    invite/
    notification/
    calendar/
    mini_window/
    settings/
supabase/
  config.toml
  migrations/     # 20261110000001_create_enums.sql のように番号順
  seed.sql        # 開発用のテストユーザー・チーム・付箋
  tests/          # pgTAP（RLSのテスト）
env.example.json
README.md         # セットアップ手順、無料プランの注意、バックアップ手順
```

---

## 11. 設計書の食い違いと、このプロンプトでの決定内容

実装中に設計書を参照して食い違いに気づいた場合の判断基準です。

| 設計書の記載 | 決定 |
|---|---|
| シーケンス図の Firestore / Firebase Auth | **Supabase（PostgreSQL / Auth）**に置換 |
| シーケンス図の FCM / Cloud Functions / Firebase Notification | **DBトリガーで notifications に INSERT → Realtime で受信 → Windows のローカル通知**に置換 |
| シーケンス図の「バックエンドAPI」（400 / 403 を返す） | PostgreSQL の RPC（`join_team` など）。エラーはコード付き例外で返す |
| 招待が「チーム単位」（テーブル）と「ボード単位」（シーケンス図）で混在 | **チーム単位**で招待。参加後はチーム内の全ボードを閲覧可 |
| task テーブルに board_id・座標・開始日・色・一言メッセージがない | ドメインモデル図・機能要件に合わせて §5.3 のとおり追加 |
| task_member が team_member_id を参照 | user_id を参照に変更（RLSを単純にするため） |
| ステータスが `done` と `completed` で混在 | `todo / in_progress / done` に統一 |
| 優先度が「高・中・低」と画面モックの「P1」で混在 | `high / medium / low`（表示は 高・中・低）に統一 |
| user テーブルに password_hash がある | Supabase Auth が管理するので profiles には作らない |
| team_invite に `created_by` が2つある（2つ目は作成日） | 2つ目を `created_at` に修正 |
| task の updated_at の論理名が「削除日」 | 更新日として扱い、削除日は `deleted_at` を追加 |
| 列名の誤字（joinde_at, invitaion_id, failded_attempts, varcher） | 正しい綴りで作成 |
| 画面ID P0-04 が「パスコード再発行」だが中身はメール送信完了 | パスワード再設定（コード方式）の画面として実装 |
| ボード画面の「完」ボタンの意味が不明 | 完了ログ（P1-07）を開くボタンと解釈 |

この表以外で矛盾を見つけたら、実装を止めて私に確認してください。
