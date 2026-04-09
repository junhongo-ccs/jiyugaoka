# coffee_shops 位置監査メモ

作成日: 2026-04-09

## 前提

- 正データは `data/coffee_shops.csv`
- QGIS プロジェクト `jiyugaokaqgz.qgz` 内では、`coffee_shops` は CSV 直読ではなく `public.coffee_shops` を PostgreSQL から参照している

## 確認結果

### 1. `data/coffee_shops.csv` と `init.sql`

- 件数: 31 / 31
- `source_id`: 全件一致
- 店名: 全件一致
- 緯度経度: 全件一致

結論:

- repo 管理下の `init.sql` にある `coffee_shops` 初期データには、`data/coffee_shops.csv` との差分は見つからなかった

### 2. `data/favorites.csv` と `data/coffee_shops.csv`

- 対象 4 件すべてで店名・緯度経度とも一致

### 3. QGIS プロジェクト定義

- `jiyugaokaqgz.qgz` を展開して確認
- `coffee_shops` レイヤのデータソース:
  - `dbname='postgres' ... table="public"."coffee_shops" (geom)`
- `home` レイヤは `data/home.csv` を `xField=longitude`, `yField=latitude` で参照

結論:

- repo 上の QGIS プロジェクト定義に、`coffee_shops.csv` と食い違う別座標の埋め込みは見つからなかった

## 位置ずれリスト

現時点では、repo 管理下のファイル比較だけでは `coffee_shops.csv` とずれているスポットは `0 件`。

## 次に疑うべき箇所

- ローカル PostgreSQL の `public.coffee_shops`
  - QGIS はここを読んでいるため、DB にだけ古い座標が残っていると repo との差分が発生する
- QGIS 上で手修正した一時レイヤ
- 手元の別 CSV を QGIS に追加しているケース

## 追加で必要なもの

次を取れれば、実際のずれリストを確定できる。

- `public.coffee_shops` のエクスポート
- もしくは QGIS 側で今表示している `coffee_shops` レイヤの属性テーブル出力

