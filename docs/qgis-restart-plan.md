# QGIS 再開タスク計画

## 目的

QGIS 再起動後に、自由が丘の珈琲屋スポットを最短で復元し、安定した状態で再開する。

今回の主目的はこれだけです。

- `coffee_shops` 31件を地図に出す
- 背景に `CartoDB Positron` を敷く
- 店名ラベルを出す
- 落ちる前に `qgz` を保存する

## 現在できていること

- PostgreSQL は `localhost:5432` で起動済み
- PostGIS は有効化済み
- `init.sql` 実行済み
- DB 件数
  - `buildings = 2`
  - `roads = 3`
  - `coffee_shops = 31`
- `coffee_shops` は QGIS で一度読み込めている
- `coffee_shops` を `Zoom to Layer(s)` すると自由が丘周辺まで飛べることを確認済み
- `CartoDB Positron` も QGIS に追加済み
- `UTAKATA COFFEE` は現地確認ベースで座標を再修正済み
  - `35.604906024507784, 139.6715276097942`

## 明日の主目的

`coffee_shops` の点表示を眺めるだけでなく、自由通り沿いに店が連なる軸を `road` として可視化する。

地元感覚としては「一帯」より、真っ直ぐ伸びた `自由通り` に沿ってコーヒー店が点在している見え方が本質に近い。

明日は次の 2 点をやれば十分。

- `coffee_shops` の最新座標を前提に表示を確認する
- `自由通り` を表すラインレイヤを 1 本追加する

## 接続情報

- Host: `localhost`
- Port: `5432`
- Database: `postgres`
- Username: `hongoujun`
- Connection Name: `jiyugaoka`

## 再開時の最短手順

### 1. QGIS を開く

白紙状態からでよい。

### 2. 背景を入れる

左の `XYZ Tiles` から `CartoDB Positron` を地図へドラッグする。

もし接続が消えていたら:

- `XYZ Tiles` を右クリック
- `New Connection...`
- `Name`: `CartoDB Positron`
- `URL`: `https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png`

### 3. PostgreSQL に接続する

- 左の `PostgreSQL` を右クリック
- `New Connection...`
- 接続情報は上記のとおり
- `Test Connection`
- `OK`

### 4. 珈琲屋レイヤを読む

- `PostgreSQL > jiyugaoka > public > coffee_shops`
- これを地図へドラッグ

### 5. 自由が丘まで寄る

- 左下の `Layers` で `coffee_shops` を右クリック
- `Zoom to Layer(s)`

ここで自由が丘・奥沢・九品仏周辺に 31 点が見えれば復旧成功。

## 最低限の見た目設定

### シンボル

- `coffee_shops` を右クリック
- `Properties...`
- `Symbology`
- 色: 茶色
- サイズ: `2.8`
- `Apply`

### ラベル

- `Labels`
- `Single Labels`
- `Value = name`
- `Apply`

### ラベルの白フチ

- `Buffer`
- `Draw text buffer` をオン
- 色: 白
- 太さ: `1`
- `Apply`

## 落ちやすいので先にやること

ラベルが出たら、見た目の調整を続ける前に保存する。

- `Project` → `Save To` → `File...`
- 保存先:
  - `/Users/hongoujun/Documents/GitHub/jiyugaoka/coffee-map.qgz`

もし `Save To` が見当たらなければ:

- `Project` → `Save As...`
- 同じ保存先を指定する

## 今回はやらないこと

QGIS が不安定なので、次の作業は後回しにする。

- `Temporal Controller`
- `buildings` と `roads` の調整
- 再開発ポリゴンの描き直し
- 3D Map View
- 複雑なラベル調整

次回の主眼は `coffee_shops` の表示だけに絞る。

ただし明日は例外として、`自由通り` の軸線だけは追加してよい。

## 失敗時の切り分け

### 背景だけ出て世界地図のまま

`coffee_shops` をまだズームしていない。

- `coffee_shops` を右クリック
- `Zoom to Layer(s)`

### `coffee_shops` が見つからない

`init.sql` を流し直す。

```bash
/Applications/Postgres.app/Contents/Versions/18/bin/psql -h localhost -p 5432 -d postgres -U hongoujun -f /Users/hongoujun/Documents/GitHub/jiyugaoka/init.sql
```

### QGIS がまた落ちる

復旧時は以下だけに絞る。

- `CartoDB Positron`
- `coffee_shops`
- `Zoom to Layer(s)`
- `Save As...`

## 次回の再開メモ

成功ラインはこれ。

1. 背景が出る
2. `coffee_shops` が出る
3. `Zoom to Layer(s)` で自由が丘へ飛ぶ
4. 店名ラベルが出る
5. `自由通り` のラインレイヤを 1 本描く
6. `coffee-map.qgz` を保存する

ここまでできたら、QGIS 側の今回の目標は達成。

## 明日の実作業タスク

### 1. `coffee_shops` の状態確認

- `PostgreSQL > jiyugaoka > public > coffee_shops` を読む
- `UTAKATA COFFEE` が修正後の位置にあることを確認する
- 必要なら `Zoom to Layer(s)` で自由が丘周辺へ寄る

### 2. `自由通り` 用のラインレイヤを作る

- `Layer` → `Create Layer` → `New GeoPackage Layer...`
- Geometry type は `LineString`
- ファイル名は例として `annotations.gpkg`
- レイヤ名は `coffee_street_axis`
- 属性は `name` のみでよい

### 3. 軸線を手で引く

- 編集モードに入る
- `Add Line Feature` で、自由通りの北側から南側へ 1 本の線を引く
- 属性 `name` は `自由通り` か `Coffee Street` とする

### 4. 見た目を注記レイヤとして整える

- 色は茶系か赤茶系
- 線幅は少し太め
- 必要なら破線にする
- ラベルをオンにして、道路軸の説明として読める状態にする

### 5. 保存

- `coffee-map.qgz` を保存する
- 可能ならスクリーンショットも 1 枚残す
