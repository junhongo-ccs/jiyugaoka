# 自由が丘再開発マップ PoC 詳細仕様

## 1. 目的

自由が丘駅周辺の再開発と街路整備を、公式資料ベースの空間データと時間軸で可視化する。

この PoC では、以下を一連の成果物として成立させる。

- 2023 年時点の低層商業代表点の記録
- 2026 年の再開発区域代表点の記録
- 2026 年の道路整備区間の表現
- QGIS での時間スライダーによる変化再生
- SQL 分析結果をもとにした Markdown レポート生成

## 2. 背景

自由が丘は低層商業の街として認知されてきた一方、駅前再開発と道路基盤整備によって駅周辺の景観と回遊導線が変化しつつある。

本 PoC は、感覚的な印象ではなく、目黒区公開資料に基づく区域と道路を最小単位として扱い、誰が見ても分かる変化マップに落とし込むことを狙う。

## 3. スコープ

### 3.1 対象範囲

- 地理範囲は自由が丘駅北西側の再開発区域周辺
- 主対象は `buildings` の代表点と `roads` の整備区間
- 年次対象は 2023 年と 2026 年

### 3.2 今回やること

- PostGIS 上に `buildings` と `roads` テーブルを作成する
- 公式資料ベースの簡略データを投入する
- QGIS で地図表示、ラベル表示、スタイル設定、時間スライダー設定を行う
- 俯瞰風の PNG または 3D 表示を出力する
- SQL クエリとその結果をもとにした説明文テンプレートを整備する

### 3.3 今回やらないこと

- 建物フットプリントの厳密な Polygon 化
- 道路台帳レベルの厳密な線形復元
- 民間不動産データの混在
- WebGIS の本格実装

## 4. データモデル

### 4.1 buildings

- `id`: `SERIAL PRIMARY KEY`
- `name`: `TEXT NOT NULL`
- `geom`: `GEOMETRY(Point, 4326) NOT NULL`
- `status`: `TEXT NOT NULL`
- `year`: `INTEGER NOT NULL`
- `description`: `TEXT`

ステータス:

- `低層商業`
- `再開発予定`

### 4.2 roads

- `id`: `SERIAL PRIMARY KEY`
- `name`: `TEXT NOT NULL`
- `geom`: `GEOMETRY(LineString, 4326) NOT NULL`
- `status`: `TEXT NOT NULL`
- `year`: `INTEGER NOT NULL`
- `description`: `TEXT`

ステータス:

- `道路拡幅`

## 5. 初期データ方針

### 5.1 buildings

- `旧低層雑貨街`: 2023 年の比較用代表点
- `自由が丘一丁目29番地区`: 目黒区公開資料の施行区域図に基づく代表点

### 5.2 roads

- `補助46号線（すずかけ通り）整備区間`
- `区道H100号線（女神通り）整備区間`
- `補助127号線（カトレア通り）整備区間`

### 5.3 注意

- `自由が丘一丁目29番地区` は公開資料の施行区域図に基づく代表点であり、測量成果座標ではない
- `roads` は公開区域図をもとにした簡略線であり、道路台帳の厳密線形ではない
- 旧データにあった `自由が丘駅前タワー` と `奥沢7丁目新築戸建` は本体から外す

## 6. 公式資料

- 目黒区 自由が丘一丁目29番地区第一種市街地再開発事業 事業計画書
  - https://www.city.meguro.tokyo.jp/documents/4995/2411_jigyoukeikakuhenkou.pdf
- 目黒区 市街地再開発事業の都市計画
  - https://www.city.meguro.tokyo.jp/documents/4998/saikaihatu1.pdf

## 7. QGIS 要件

- プロジェクト CRS: `EPSG:4326`
- レイヤ:
  - `buildings`: 点
  - `roads`: 線
- 背景:
  - `CartoDB Positron` など淡色ベースマップ
- スタイル:
  - `再開発予定`: 赤
  - `低層商業`: 青
  - `道路拡幅`: 緑の線
- ラベル:
  - `name`
- 時系列:
  - `buildings.year` と `roads.year` を日付式に変換して使用

## 8. 分析要件

`queries.sql` に最低限以下を含める。

1. 2023 年の低層商業代表点と 2026 年の再開発代表点の距離比較
2. 再開発代表点から各道路整備線までの距離比較
3. `buildings` / `roads` 横断の件数集計
4. GeoJSON 出力

## 9. 成果物

- `init.sql`
- `queries.sql`
- `qgis-project.qgz`
- `screenshots/`
- `reports/`
- `README.md`

## 10. 受け入れ条件

- PostGIS に `init.sql` を実行して `buildings` と `roads` が作成される
- `buildings` に 2 件、`roads` に 3 件の初期データが入る
- QGIS で `buildings` と `roads` を表示できる
- 時間範囲を変えると 2023 年の低層商業と 2026 年の再開発・道路整備が切り替わる
- `自由が丘一丁目29番地区` が公開資料の施行区域付近に表示される
