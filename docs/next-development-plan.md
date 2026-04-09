# 次回以降の開発プラン

## 目的

いまの QGIS / PLATEAU 試作を、その場の探索で終わらせず、次回すぐ再開できる開発タスクとして固定する。

このドキュメントは次の 2 本立てで進める前提とする。

- QGIS でのローカル探索と可視化の継続
- GitHub Pages 向け Web 実装への落とし込み

## 現在地点

現時点でできていること:

- `coffee_shops` を QGIS 上で表示できる
- `home.csv` を追加し、自宅ポイントを表示できる
- PLATEAU `目黒区 2025` の CityGML を取得済み
- 自由が丘周辺のみを切り出した建物 GeoJSON を生成済み
- `jiyugaoka_plateau_buildings.geojson` を QGIS で 3D 押し出し表示できる
- `coffee_shops` にコーヒーカップ `OBJ` を割り当てることができる

関連ファイル:

- `data/home.csv`
- `data/favorites.csv`
- `data/plateau/jiyugaoka_plateau_buildings.geojson`
- `data/plateau/jiyugaoka_plateau_buildings.meta.json`
- `data/models/coffee_cup_lowpoly.obj`
- `data/models/coffee_cup_lowpoly.mtl`
- `scripts/extract_plateau_buildings.py`

## 次回の優先順位

優先度は以下の順にする。

1. QGIS 側の成果を保存し、再現可能な状態に固める
2. GitHub Pages に載せるための静的成果物を整える
3. 本気の 3D Web 実装として `PLATEAU 3D Tiles + CesiumJS` を始める

## トラック A: QGIS 側の整理

### A-1. プロジェクト保存

- `qgz` を保存する
- `Spatial Bookmark` で `自由が丘` を保存する
- 3D ビューの見やすい構図でスクリーンショットを残す

### A-2. レイヤ整理

- `coffee_shops` は 3D カップ表示用として使う
- `home` は目立つ単独マーカーにする
- `favorites.csv` は 3D でも読める少数ラベル用レイヤとして使う
- `buildings` と `roads` は今回のカフェ地図用途では一旦非表示でよい

### A-3. 見た目の固定

- 建物は薄いグレー
- `coffee_shops` はコーヒーカップ `OBJ`
- `home` は別色の目立つマーカー
- 必要なら `favorites` のみラベルを出す

## トラック B: GitHub Pages 向けの短期実装

QGIS そのものは GitHub Pages に載らないため、静的サイトとして再構成する。

### B-1. 最短の公開形

- 3D ビューのスクリーンショットを `screenshots/` に出力
- 2D 地図と 3D スクリーンショットを並べる紹介ページを作る
- `home.csv` と `coffee_shops.csv` を Web ページから参照する

### B-2. 追加でやるとよいこと

- `favorites.csv` を使ったおすすめスポット表示
- `jiyugaoka_plateau_buildings.geojson` の概要説明を追加
- QGIS で作った 3D カップ地図のスクリーンショットを成果物リンクに追加

### B-3. 実装タスク

- `src/main.js` を現在の再開発 PoC から、カフェ + 自宅 + PLATEAU 紹介ページに寄せる
- `README.md` に Web 公開の見方を追記する
- `screenshots/` に 3D 完成図を保存する
- `main` に push して GitHub Pages を更新する

## トラック C: 本気の 3D Web 実装

次回以降の大きなテーマ。これは夜中に片手間でやるより、まとまった時間で進める。

### C-1. ゴール

- PLATEAU の `3D Tiles` をブラウザで読む
- 自由が丘周辺を CesiumJS で表示する
- `home` と `coffee_shops` を 3D 上に重ねる
- GitHub Pages で見られる状態にする

### C-2. 技術方針

- 3D 建物は QGIS ではなく Web 側で描画する
- 3D 描画ライブラリは `CesiumJS` を第一候補とする
- QGIS で作った見え方は構図参考として使い、公開ビューは Web で再構築する

### C-3. タスク分解

1. PLATEAU の `3D Tiles` 配布物を取得する
2. 自由が丘周辺だけの初期表示位置を決める
3. `CesiumJS` の最小表示を Vite 上で立ち上げる
4. `home.csv` と `coffee_shops.csv` を読み込み、ポイント表示する
5. カメラ初期位置とズーム範囲を調整する
6. GitHub Pages で動くアセット配置にする

### C-4. 懸念点

- `3D Tiles` の配信サイズが重い可能性がある
- GitHub Pages では大きな 3D アセットの置き方を考える必要がある
- CORS や外部配信先の選定が必要になる場合がある

## 再開時の最短チェックリスト

次回はこれだけ見ればよい。

1. `docs/qgis-restart-plan.md` を確認する
2. `docs/next-development-plan.md` を確認する
3. まず QGIS の成果を `qgz` とスクリーンショットで固定する
4. その後、GitHub Pages へ何を載せるかを決める
5. 時間が十分ある時だけ `CesiumJS + 3D Tiles` に着手する

## 次回の開始文

次回はこの文で再開すればよい。

`Cesium で PLATEAU の 3D Tiles を GitHub Pages に載せる続きから。まずは今ある QGIS 成果を固定して、次に Web 側の最小 3D 表示を作る。`
