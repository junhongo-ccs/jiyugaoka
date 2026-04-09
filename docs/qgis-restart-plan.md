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
5. `coffee-map.qgz` を保存する

ここまでできたら、QGIS 側の今回の目標は達成。
