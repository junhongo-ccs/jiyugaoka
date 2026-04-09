CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS coffee_shops;
DROP TABLE IF EXISTS roads;
DROP TABLE IF EXISTS buildings;

CREATE TABLE buildings (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom GEOMETRY(Point, 4326) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('低層商業', '再開発予定')),
  year INTEGER NOT NULL CHECK (year IN (2023, 2026)),
  description TEXT
);

CREATE TABLE roads (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom GEOMETRY(LineString, 4326) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('道路拡幅')),
  year INTEGER NOT NULL CHECK (year IN (2026)),
  description TEXT
);

CREATE TABLE coffee_shops (
  id SERIAL PRIMARY KEY,
  source_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  geom GEOMETRY(Point, 4326) NOT NULL,
  category TEXT NOT NULL,
  tags TEXT,
  description TEXT
);

INSERT INTO buildings (name, geom, status, year, description) VALUES
(
  '旧低層雑貨街',
  ST_SetSRID(ST_MakePoint(139.66785, 35.60772), 4326),
  '低層商業',
  2023,
  '自由が丘駅北西側の低層商業地の記憶を示す比較用代表点'
),
(
  '自由が丘一丁目29番地区',
  ST_SetSRID(ST_MakePoint(139.66815, 35.60788), 4326),
  '再開発予定',
  2026,
  '目黒区公開資料の施行区域図に基づく代表点。補助46号線・補助127号線・区道H100号線に囲まれた区域'
);

INSERT INTO roads (name, geom, status, year, description) VALUES
(
  '補助46号線（すずかけ通り）整備区間',
  ST_SetSRID(
    ST_MakeLine(ARRAY[
      ST_MakePoint(139.66752, 35.60832),
      ST_MakePoint(139.66862, 35.60830)
    ]),
    4326
  ),
  '道路拡幅',
  2026,
  '自由が丘一丁目29番地区北側の整備対象道路。公開区域図をもとにした簡略線'
),
(
  '区道H100号線（女神通り）整備区間',
  ST_SetSRID(
    ST_MakeLine(ARRAY[
      ST_MakePoint(139.66844, 35.60752),
      ST_MakePoint(139.66826, 35.60808)
    ]),
    4326
  ),
  '道路拡幅',
  2026,
  '自由が丘一丁目29番地区東側の整備対象道路。公開区域図をもとにした簡略線'
),
(
  '補助127号線（カトレア通り）整備区間',
  ST_SetSRID(
    ST_MakeLine(ARRAY[
      ST_MakePoint(139.66772, 35.60755),
      ST_MakePoint(139.66818, 35.60756)
    ]),
    4326
  ),
  '道路拡幅',
  2026,
  '自由が丘一丁目29番地区南側の整備対象道路。公開区域図をもとにした簡略線'
);

INSERT INTO coffee_shops (source_id, name, address, geom, category, tags, description) VALUES
(
  'curated-amber',
  'amber',
  '東京都世田谷区奥沢5-42-3 トレインチ自由が丘 2F',
  ST_SetSRID(ST_MakePoint(139.6668125, 35.6065625), 4326),
  'coffee_shop',
  'study|spacious|specialty|quiet|atmosphere|cozy',
  'スペシャルティコーヒー店です。店内で作業している人も多く、隣棟の SHARE LOUNGE を時間利用できる点も含めて仕事や長居できます。'
),
(
  'curated-onnibus',
  'ONIBUS COFFEE 自由が丘店',
  '東京都目黒区緑が丘2-24-8 arbre自由が丘',
  ST_SetSRID(ST_MakePoint(139.6718125, 35.6085625), 4326),
  'coffee_shop',
  'quiet|study|specialty|morning',
  '店内も広い自由が丘駅近のスペシャルティ系カフェです。'
),
(
  'curated-compass-kuhonbutsu',
  'コンパスコーヒー 九品仏店',
  '東京都世田谷区奥沢6-13-7',
  ST_SetSRID(ST_MakePoint(139.6613125, 35.6044375), 4326),
  'both',
  'roastery|specialty|quiet|cozy',
  '九品仏駅近くで豆選びと店内利用の両方に寄せやすい、ロースト志向のコーヒー店です。'
),
(
  'curated-aranciato',
  'Cafe Aranciato',
  '東京都世田谷区奥沢4-27-16',
  ST_SetSRID(ST_MakePoint(139.6718125, 35.6031875), 4326),
  'both',
  'quiet|cozy|roastery|specialty',
  '奥沢側で落ち着いて過ごしやすく、コーヒー豆販売にも寄せられるロースターカフェです。'
),
(
  'curated-chanoko',
  'CHANOKO COFFEE ROASTERY',
  '東京都世田谷区奥沢2-12-6 平井ビル1F',
  ST_SetSRID(ST_MakePoint(139.6715625, 35.6055625), 4326),
  'both',
  'roastery|specialty|quiet|cozy',
  '奥沢神社近くの小さなロースタリーカフェです。豆販売もあり、一人で静かに過ごしたいときにもおすすめ。'
),
(
  'curated-ueshima-okusawa',
  '上島珈琲店 奥沢店',
  '東京都世田谷区奥沢2-12-10 自由が丘サウスヒルズ',
  ST_SetSRID(ST_MakePoint(139.6715625, 35.6058125), 4326),
  'coffee_shop',
  'study|spacious|cozy|morning',
  '奥沢2丁目で席数があり、作業や勉強の受け皿として使いやすい定番カフェです。'
),
(
  'curated-starbucks-okusawa-2',
  'スターバックス コーヒー 奥沢2丁目店',
  '東京都世田谷区奥沢2丁目38-9',
  ST_SetSRID(ST_MakePoint(139.6712092, 35.607391), 4326),
  'coffee_shop',
  'study|spacious|atmosphere|specialty',
  'チェーン店ながら価格帯がやや上で、木材を多用したリラックスでモダンな空間が特徴の奥沢側候補です。'
),
(
  'curated-sunset',
  'Sunset Coffee Jiyugaoka',
  '東京都目黒区自由が丘1-26-14 オクミズビル1F',
  ST_SetSRID(ST_MakePoint(139.6684375, 35.6093125), 4326),
  'coffee_stand',
  'coffee_stand|roastery|specialty|morning|atmosphere',
  '自由が丘駅近の小さなコーヒースタンドで、短時間の一杯やテイクアウトにおすすめです。'
),
(
  'curated-alpha-beta',
  'アルファ・ベータ・コーヒー・クラブ 自由が丘駅前店',
  '東京都目黒区自由が丘2-10-4 ミルシェ自由が丘 3F',
  ST_SetSRID(ST_MakePoint(139.6680625, 35.6081875), 4326),
  'coffee_shop',
  'study|specialty|atmosphere|quiet',
  '自由が丘駅すぐ。PC を開いて作業している人も多い、作業利用にもおすすめでコーヒーもおいしい。'
),
(
  'curated-kissa20',
  '喫茶二十世紀',
  '東京都目黒区自由が丘2-16-19',
  ST_SetSRID(ST_MakePoint(139.6658125, 35.6090625), 4326),
  'coffee_shop',
  'quiet|cozy|atmosphere|sweet',
  '喫茶店寄りの落ち着いた時間を取りたいときに向く候補です。'
),
(
  'curated-crossing',
  'クロッシング コーヒーロースターズ',
  '東京都目黒区自由が丘1-14-1 Gタワー 1F',
  ST_SetSRID(ST_MakePoint(139.6701875, 35.6096875), 4326),
  'both',
  'roastery|specialty|morning|quiet',
  '焙煎文脈が強く、豆も見たいときに寄せやすいロースター系候補です。'
),
(
  'curated-la-boheme',
  'カフェ ラ・ボエム 自由が丘',
  '東京都目黒区自由が丘1-4-8 1F・2F',
  ST_SetSRID(ST_MakePoint(139.6709375, 35.6083125), 4326),
  'coffee_shop',
  'spacious|atmosphere|sweet|morning',
  '席数と入りやすさがあり、会話や軽い滞在の受け皿になりやすい大型店です。'
),
(
  'curated-the-jiyugaoka',
  'the;自由が丘',
  '東京都目黒区緑が丘2-17-12 T''S BRIGHTIA自由が丘 102号',
  ST_SetSRID(ST_MakePoint(139.6723125, 35.6085625), 4326),
  'coffee_shop',
  'atmosphere|cozy|quiet|specialty',
  'ペット同伴でスペシャルティコーヒーが味わえるカフェ＆バーラウンジ。'
),
(
  'curated-slow-stand',
  'Slow Standard Coffee',
  '東京都世田谷区奥沢2-46-6 自由が丘apartment 102',
  ST_SetSRID(ST_MakePoint(139.6759375, 35.6075625), 4326),
  'coffee_stand',
  'morning|specialty|cozy|quiet',
  '奥沢2丁目で落ち着いて過ごしやすく、焙煎や豆販売の文脈でも拾えるニーズにもおすすめのスペシャルティ候補です。'
),
(
  'curated-cafe-skoll',
  'Cafe Skoll',
  '東京都目黒区自由が丘1-9-6 オハナビル 2F',
  ST_SetSRID(ST_MakePoint(139.6691875, 35.6073125), 4326),
  'coffee_shop',
  'study|quiet|cozy|atmosphere',
  '自由が丘中心から少し南にあり、食事やスイーツと一緒にゆっくり過ごしやすいカフェ寄りの候補です。'
),
(
  'curated-ebony',
  'EBONY COFFEE',
  '東京都世田谷区奥沢6-28-4 ワイズニール自由ヶ丘 1F',
  ST_SetSRID(ST_MakePoint(139.6640625, 35.6053125), 4326),
  'bean_store',
  'specialty|roastery|beans_only',
  '店内提供やテイクアウトを行わない、焙煎豆専門のロースターです。'
),
(
  'curated-stamp',
  'STAMP COFFEE / スタンプコーヒー',
  '東京都世田谷区奥沢5-31-20',
  ST_SetSRID(ST_MakePoint(139.6678125, 35.6046875), 4326),
  'coffee_stand',
  'specialty|morning|cozy|atmosphere',
  'ハンドドリップのコーヒーと、シンプルなトーストメニューをいただけます。'
),
(
  'curated-miyachi-shoten',
  'ミヤチ商店',
  '東京都世田谷区奥沢5-1-4',
  ST_SetSRID(ST_MakePoint(139.6711875, 35.6036875), 4326),
  'coffee_stand',
  'coffee_stand|morning|cozy|quiet|specialty',
  '奥沢5丁目の小さなコーヒースタンドで、朝の一杯や短時間の立ち寄りにおすすめです。'
),
(
  'curated-utakata',
  'UTAKATA COFFEE',
  '東京都世田谷区奥沢5-14-31 クレインI 101',
  ST_SetSRID(ST_MakePoint(139.67244390418, 35.603981238679), 4326),
  'coffee_shop',
  'atmosphere|cozy|quiet|specialty',
  '奥沢南東側で、雰囲気重視や静かな時間に寄せやすいコーヒー候補です。'
),
(
  'curated-enseigne-angle',
  'カフェ・アンセーニュ・ダングル 自由が丘店',
  '東京都目黒区自由が丘1-13-6 鳥井ビル1F',
  ST_SetSRID(ST_MakePoint(139.6702441, 35.6080411), 4326),
  'coffee_shop',
  'quiet|cozy|specialty|atmosphere',
  'クラシカルな喫茶店文脈が強く、静かな会話や落ち着いた一杯を重視したいときに向きます。'
),
(
  'curated-mamocafe',
  'Specialtycoffee&Food mamocafe',
  '東京都目黒区緑が丘2-4-5',
  ST_SetSRID(ST_MakePoint(139.6788, 35.6081), 4326),
  'coffee_shop',
  'specialty|cozy|quiet|sweet',
  '小さめの落ち着いた空気感で、スペシャルティ寄りの一杯を取りたいときの候補です。'
),
(
  'curated-latte-graphic',
  'LATTE GRAPHIC 自由が丘店',
  '東京都目黒区自由が丘1-8-18 自由が丘ノーブル 2F',
  ST_SetSRID(ST_MakePoint(139.6688125, 35.6069375), 4326),
  'coffee_shop',
  'spacious|study|morning|atmosphere',
  '比較的入りやすく、会話や軽い作業の受け皿にもなりやすい大型寄りの候補です。'
),
(
  'curated-cafe-mozart',
  'カフェ モーツァルト 自由が丘店',
  '東京都目黒区自由が丘1-8-2 サウスゲートビル 2F',
  ST_SetSRID(ST_MakePoint(139.6752, 35.6082), 4326),
  'coffee_shop',
  'cozy|sweet|atmosphere|quiet',
  'コーヒーとケーキのセット需要が強く、喫茶店ベクトルでゆっくり過ごしたいときに向く候補です。'
),
(
  'curated-usubane',
  'usubane',
  '東京都目黒区自由が丘2-12-19 B1',
  ST_SetSRID(ST_MakePoint(139.6674375, 35.6071875), 4326),
  'coffee_shop',
  'quiet|cozy|atmosphere|specialty',
  '自由が丘西側で、雰囲気と静かな時間を重視したいときにおすすめです。'
),
(
  'curated-royal-crystal',
  'ロイヤルクリスタルコーヒー',
  '東京都目黒区自由が丘2-16-3',
  ST_SetSRID(ST_MakePoint(139.6670625, 35.6084375), 4326),
  'coffee_shop',
  'quiet|cozy|atmosphere|sweet',
  '落ち着いてゆっくり飲む方向に寄せやすい、クラシック寄りのコーヒー候補です。'
),
(
  'curated-stillpark',
  'STILLPARK',
  '東京都世田谷区奥沢4-5-4',
  ST_SetSRID(ST_MakePoint(139.6689375, 35.5999375), 4326),
  'coffee_shop',
  'cozy|quiet|atmosphere|morning',
  '奥沢4丁目の小さめのコーヒーショップで、静かな時間を取りたいときにおすすめです。'
),
(
  'curated-relief-coffee-stand',
  'Relief coffee stand',
  '東京都世田谷区奥沢4-4-7 スカイハイツ奥沢 1F',
  ST_SetSRID(ST_MakePoint(139.6698125, 35.5998125), 4326),
  'coffee_stand',
  'morning|specialty|cozy|quiet',
  '奥沢4丁目の小さなコーヒースタンドで、朝の一杯や短時間利用におすすめです。'
),
(
  'curated-la-cialda',
  'La Cialda -自由が丘カフェ-',
  '東京都目黒区自由が丘1-25-9 1F',
  ST_SetSRID(ST_MakePoint(139.6688125, 35.6095625), 4326),
  'coffee_shop',
  'cozy|atmosphere|sweet|morning',
  '自由が丘1丁目で入りやすく、軽食や一杯を気軽に取りたいときにおすすめです。'
),
(
  'curated-chilt',
  'CHILT CAFESTAND & CRAFT',
  '東京都世田谷区奥沢7-6-10',
  ST_SetSRID(ST_MakePoint(139.6646875, 35.6075625), 4326),
  'coffee_shop',
  'atmosphere|cozy|quiet|specialty',
  '九品仏から奥沢寄りの南側で、雰囲気重視や一人時間におすすめです。'
),
(
  'curated-radio-plant',
  'ラジオプラント',
  '東京都世田谷区奥沢7-7-21 Casa Abierta 1階',
  ST_SetSRID(ST_MakePoint(139.6650625, 35.6064375), 4326),
  'coffee_shop',
  'quiet|cozy|atmosphere|sweet',
  '静かなジャズが流れる店内で、長居したくなるような居心地のよさがある喫茶寄りの候補です。'
),
(
  'curated-alpha-beta-2',
  'アルファベータコーヒークラブ
自由が丘コンコード店',
  '東京都目黒区自由が丘 2-9-24 自由が丘コンコード 1F',
  ST_SetSRID(ST_MakePoint(139.6681489, 35.6096406), 4326),
  'coffee_shop',
  'study|specialty|atmosphere|quiet',
  'ハンドドリップと充実の軽食が魅力です。開放感ある店内のソファ席や、ペット可のテラスで会話を楽しみたい時に最適。'
);

CREATE INDEX buildings_geom_idx ON buildings USING GIST (geom);
CREATE INDEX buildings_year_idx ON buildings (year);
CREATE INDEX buildings_status_idx ON buildings (status);

CREATE INDEX roads_geom_idx ON roads USING GIST (geom);
CREATE INDEX roads_year_idx ON roads (year);
CREATE INDEX roads_status_idx ON roads (status);

CREATE INDEX coffee_shops_geom_idx ON coffee_shops USING GIST (geom);
CREATE INDEX coffee_shops_source_id_idx ON coffee_shops (source_id);
CREATE INDEX coffee_shops_category_idx ON coffee_shops (category);
