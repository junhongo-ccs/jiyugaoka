# Mac Codex 指示書: `public.coffee_shops` の座標更新

このリポジトリでは CSV / SQL の修正は済んでいるが、Windows 側からは Mac 上の PostgreSQL に接続できなかった。

Mac 側の Codex では、ローカル PostgreSQL の `public.coffee_shops` に入っている既存データを直接更新してほしい。

## やること

1. Mac 上で PostgreSQL に接続する
2. `public.coffee_shops` が存在することを確認する
3. 次の 3 店舗だけ `geom` を更新する
4. 更新後の座標を `SELECT` で確認する
5. 可能なら QGIS で再読込して位置を目視確認する

## 更新対象

- `curated-utakata`
  - name: `UTAKATA COFFEE`
  - new lat/lon: `35.604906024507784`, `139.6715276097942`
- `curated-starbucks-okusawa-2`
  - name: `スターバックス コーヒー 奥沢2丁目店`
  - new lat/lon: `35.607391`, `139.6712092`
- `curated-alpha-beta-2`
  - name: `アルファベータコーヒークラブ 自由が丘コンコード店`
  - new lat/lon: `35.6096406`, `139.6681489`

## 実行 SQL

```sql
UPDATE public.coffee_shops
SET geom = ST_SetSRID(ST_MakePoint(139.6715276097942, 35.604906024507784), 4326)
WHERE source_id = 'curated-utakata';

UPDATE public.coffee_shops
SET geom = ST_SetSRID(ST_MakePoint(139.6712092, 35.607391), 4326)
WHERE source_id = 'curated-starbucks-okusawa-2';

UPDATE public.coffee_shops
SET geom = ST_SetSRID(ST_MakePoint(139.6681489, 35.6096406), 4326)
WHERE source_id = 'curated-alpha-beta-2';
```

## 確認 SQL

```sql
SELECT
  source_id,
  name,
  ST_Y(geom) AS latitude,
  ST_X(geom) AS longitude
FROM public.coffee_shops
WHERE source_id IN (
  'curated-utakata',
  'curated-starbucks-okusawa-2',
  'curated-alpha-beta-2'
)
ORDER BY source_id;
```

## 補足

- すでにこの Windows 側 repo では次のファイルが更新済み:
  - `data/coffee_shops.csv`
  - `data/favorites.csv`
  - `init.sql`
- つまり Mac 側で必要なのは DB の既存行更新だけ
- `source_id` を条件にするので、店名改行の影響を受けず安全
