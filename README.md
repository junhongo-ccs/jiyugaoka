# Jiyugaoka Redevelopment Map PoC

自由が丘駅周辺の再開発を、公式資料ベースで PostGIS と QGIS により時系列可視化する PoC リポジトリ。

現在の最小構成は、`自由が丘一丁目29番地区` の再開発代表点と、その周辺道路整備区間を扱います。旧版に含めていた `自由が丘駅前タワー` と `奥沢7丁目新築戸建` は、公式資料基準の本体データから外しました。

## 成果物

- `init.sql`: PostGIS テーブル定義と初期データ
- `queries.sql`: 再開発点と道路線の分析 SQL
- `data/buildings.json`: Web 表示用の代表点データ
- `data/roads.json`: Web 表示用の道路線データ
- `data/coffee_shops.csv`: 自由が丘・奥沢・九品仏の珈琲屋 31 件
- `docs/jiyugaoka-redevelopment-map-spec.md`: 詳細仕様
- `reports/`: CODEX CLI 用のレポート

## データ構成

- `buildings`
  - `旧低層雑貨街`
  - `自由が丘一丁目29番地区`
- `roads`
  - `補助46号線（すずかけ通り）整備区間`
  - `区道H100号線（女神通り）整備区間`
  - `補助127号線（カトレア通り）整備区間`
- `coffee_shops`
  - 自由が丘・奥沢・九品仏の珈琲屋 31 件

## 公式資料

- 事業計画書:
  https://www.city.meguro.tokyo.jp/documents/4995/2411_jigyoukeikakuhenkou.pdf
- 都市計画説明資料:
  https://www.city.meguro.tokyo.jp/documents/4998/saikaihatu1.pdf

## セットアップ

```bash
/Applications/Postgres.app/Contents/Versions/18/bin/psql -h localhost -p 5432 -d postgres -U hongoujun -f init.sql
```

QGIS では `localhost:5432 / postgres` に接続し、`buildings`、`roads`、`coffee_shops` を読み込みます。

## Coffee Map の重ね方

完成済みのコーヒーマップから、QGIS 用の CSV を取り込み済みです。

- [data/coffee_shops.csv](/Users/hongoujun/Documents/GitHub/jiyugaoka/data/coffee_shops.csv)

QGIS での読み込み:

1. `Layer` → `Add Layer` → `Add Delimited Text Layer`
2. `data/coffee_shops.csv` を選ぶ
3. `X field` = `longitude`
4. `Y field` = `latitude`
5. `Geometry CRS` = `EPSG:4326`
6. `Add`

表示のおすすめ:

- 色: 茶色
- サイズ: 2.5 〜 3
- ラベル: `name`
- 背景: `CartoDB Positron`

PostGIS に直接入れたい場合は、`init.sql` に `coffee_shops` テーブルと 31 件の初期データを組み込み済みです。`init.sql` を再実行すれば、QGIS から `public.coffee_shops` をそのまま読めます。

## QGIS メモ

- プロジェクト CRS: `EPSG:4326`
- 背景: `CartoDB Positron`
- `buildings`: 点、ラベルは `name`
- `roads`: 線、色は緑
- 時系列: `year` を `make_date()` で日付化して制御

## 補足

現在の座標は、公開資料の区域図をもとにした代表点・簡略線です。測量成果や道路台帳レベルの精度は持っていません。
