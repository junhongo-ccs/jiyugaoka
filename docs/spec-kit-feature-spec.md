# Feature Specification: Jiyugaoka Redevelopment Time-Series Map PoC

**Feature Branch**: `[001-jiyugaoka-redevelopment-map]`  
**Created**: 2026-04-08  
**Status**: Draft  
**Input**: User description: "自由が丘駅周辺の再開発を PostGIS / QGIS で時間軸マップ化し、俯瞰風 3D 表示と CODEX 生成レポートで可視化する"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - PostGIS に再開発 PoC データを投入できる (Priority: P1)

利用者として、自由が丘再開発地点の PoC データを PostGIS に投入し、QGIS で読める基本レイヤを作りたい。これにより、最低限の地図可視化が成立する。

**Why this priority**: これがないと以降の可視化、分析、レポート生成がすべて始められないため。

**Independent Test**: `init.sql` を PostgreSQL + PostGIS に実行し、`buildings` テーブルと 5 件の初期データが作成されることを確認すれば単独で価値がある。

**Acceptance Scenarios**:

1. **Given** PostGIS が有効な PostgreSQL 環境がある, **When** 利用者が `init.sql` を実行する, **Then** `buildings` テーブルが作成され GIST インデックスが付与される
2. **Given** `buildings` テーブルが作成済みである, **When** 利用者が件数確認クエリを実行する, **Then** 5 件の PoC データが登録されている

---

### User Story 2 - QGIS で年次変化を可視化できる (Priority: P1)

利用者として、2023 年から 2026 年にかけての自由が丘の変化を時間軸で見たい。これにより、低層商業地から再開発地点への変化を視覚的に理解できる。

**Why this priority**: PoC の中核価値は「時系列で見えること」にあるため。

**Independent Test**: QGIS で PostGIS レイヤを開き、`year` に応じた表示切り替えで 2023 年と 2026 年の差分が見えれば独立して価値を提供する。

**Acceptance Scenarios**:

1. **Given** QGIS が PostgreSQL に接続済みである, **When** 利用者が `buildings` レイヤを追加する, **Then** 全 5 地点が地図上に表示される
2. **Given** `year` を時間属性として設定している, **When** 利用者が 2023 年表示に切り替える, **Then** 2023 年の `低層商業` 地点だけが見える
3. **Given** `year` を時間属性として設定している, **When** 利用者が 2026 年表示に切り替える, **Then** `再開発予定` と `道路拡幅` 地点が確認できる

---

### User Story 3 - SQL 分析結果から解説レポートを生成できる (Priority: P2)

利用者として、SQL の結果をもとに CODEX CLI で解説レポートを作りたい。これにより、地図を見るだけでなく、変化の意味を文章として共有できる。

**Why this priority**: 可視化だけでは伝わりにくい変化の文脈を補完できるため。

**Independent Test**: `queries.sql` を実行した結果を入力として、Markdown 形式のレポートを 1 本生成できれば独立した成果になる。

**Acceptance Scenarios**:

1. **Given** 利用者が SQL 結果を取得している, **When** 利用者が定義済みプロンプトで CODEX CLI を実行する, **Then** 自由が丘の変化を説明する Markdown レポートが出力される

---

### User Story 4 - 俯瞰図または擬似 3D 図を書き出せる (Priority: P3)

利用者として、再開発の変化を作品的に見せる俯瞰図を出力したい。これにより、単なる GIS データ以上の表現価値を持たせられる。

**Why this priority**: PoC の魅力を高めるが、基本機能の後でも成立するため。

**Independent Test**: QGIS の 3D View または擬似 3D スタイルで PNG を 1 枚書き出せれば達成とみなせる。

**Acceptance Scenarios**:

1. **Given** QGIS でスタイル設定済みである, **When** 利用者が俯瞰視点でレンダリングする, **Then** 再開発地点と道路整備地点が強調された PNG を出力できる

---

### User Story 5 - GitHub Pages で PoC を公開できる (Priority: P2)

利用者として、GIS ツールを持たない人にも成果物を見せたいので、GitHub Pages 上で変化の概要を見せる公開ページが欲しい。

**Why this priority**: PoC を共有しやすくなり、非 GIS ユーザーにも価値が届くため。

**Independent Test**: Node.js ビルド後の静的ファイルが生成され、GitHub Pages 上で 1 ページの紹介サイトとして表示されれば成立する。

**Acceptance Scenarios**:

1. **Given** リポジトリに Node.js ベースの静的サイト構成がある, **When** 利用者が `npm run build` を実行する, **Then** 公開用の静的ファイルが出力される
2. **Given** GitHub Actions が有効である, **When** 利用者が `main` に push する, **Then** GitHub Pages にサイトがデプロイされる
3. **Given** 閲覧者が公開ページを開く, **When** ページを表示する, **Then** 年次変化の概要と主要地点の説明をブラウザ上で読める

---

### Edge Cases

- PostGIS 拡張が未有効のデータベースに対して `init.sql` を実行した場合、前提不足が明確に分かること
- 距離分析で `geometry(4326)` のまま単位を誤認しないよう、メートル系クエリは `geography` キャストを使用すること
- QGIS で 3D View が使いにくい環境でも、2D の時系列 PNG 出力だけで PoC が成立すること
- `price_up` が `NULL` の地点があっても分析クエリが壊れないこと
- GitHub Pages のベースパスがリポジトリ名付きでもアセット参照が壊れないこと

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an `init.sql` script that creates the `buildings` table in PostgreSQL with PostGIS enabled
- **FR-002**: System MUST store all PoC locations as `geometry(Point, 4326)`
- **FR-003**: System MUST load the five predefined Jiyugaoka PoC records into the database
- **FR-004**: System MUST create a GIST index on `buildings.geom`
- **FR-005**: System MUST provide a `queries.sql` file containing at least one temporal comparison query, one proximity query, one status aggregation query, and one price-up aggregation query
- **FR-006**: Users MUST be able to connect QGIS to the PostgreSQL database and display the `buildings` layer
- **FR-007**: System MUST support year-based visualization using the `year` field as the temporal driver
- **FR-008**: System MUST document QGIS styling guidance for each `status` category
- **FR-009**: System MUST define a repeatable process for exporting at least one overview image from QGIS
- **FR-010**: System MUST provide at least one reusable CODEX CLI prompt template for generating a Markdown report from SQL results
- **FR-011**: System MUST keep the MVP valid even if exact building heights or polygon footprints are unavailable
- **FR-012**: System MUST document scope limitations so PoC coordinates and descriptions are not misrepresented as authoritative planning records
- **FR-013**: System MUST provide a Node.js-based static site build for GitHub Pages publishing
- **FR-014**: System MUST use Tailwind CSS for the public-facing page styling
- **FR-015**: Users MUST be able to review the PoC summary, timeline framing, and key redevelopment points in a browser without QGIS installed
- **FR-016**: System MUST include a GitHub Actions workflow that deploys the built static site to GitHub Pages

### Key Entities *(include if feature involves data)*

- **Building Record**: 再開発地点、低層商業地点、新築地点、道路整備地点を表すポイントデータ。属性は名称、座標、状態、年次、説明、価格変化率を持つ。
- **Analysis Query**: 時系列比較、近接判定、件数集計、価格変化集計を行う SQL 定義。
- **Map Output**: QGIS 上で生成される静止画または時系列アニメーション成果物。
- **Narrative Report**: SQL 結果と地図コンテキストをもとに CODEX CLI が生成する Markdown 文書。
- **Public Web Page**: GitHub Pages 上で公開される PoC 紹介ページ。年次変化の要約と主要地点の説明を表示する。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 利用者は 15 分以内に PostgreSQL へ初期データを投入し、QGIS で地図表示を開始できる
- **SC-002**: `init.sql` 実行後、`buildings` テーブルに 5 件の PoC レコードが存在する
- **SC-003**: 利用者は QGIS 上で 2023 年表示と 2026 年表示を切り替え、少なくとも 2 種類の街の状態差分を確認できる
- **SC-004**: 利用者は 1 枚以上の俯瞰 PNG または 1 本の時系列 GIF を出力できる
- **SC-005**: 利用者は SQL 結果から Markdown レポートを 1 本生成し、再開発の変化要点を日本語で説明できる
- **SC-006**: 閲覧者は GitHub Pages 上の公開ページを開き、3 分以内に PoC の目的と時系列の見どころを理解できる

## Assumptions

- PostgreSQL と QGIS は利用者のローカルマシンにインストール済みである
- データベース接続先はローカルの `localhost:5432` を基本とする
- PoC の初期データは固定値で始め、後で公開情報に基づき更新可能である
- 背景地図は OpenStreetMap など QGIS で一般的に使えるものを使用する
- 厳密な 3D 建物モデルはスコープ外であり、MVP ではポイントとスタイル表現で十分とする
- GitHub Pages はプロジェクトサイトとして公開し、ベースパスは `/jiyugaoka/` とする
