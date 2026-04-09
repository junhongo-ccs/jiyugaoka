-- 1. 2023 年の低層商業代表点と 2026 年の再開発代表点の距離
SELECT
  b1.name AS old_name,
  b2.name AS new_name,
  ROUND(ST_Distance(b1.geom::geography, b2.geom::geography)::numeric, 2) AS distance_m
FROM buildings AS b1
JOIN buildings AS b2
  ON b1.year = 2023
 AND b2.year = 2026
WHERE b1.status = '低層商業'
  AND b2.status = '再開発予定';

-- 2. 再開発代表点から各道路整備線までの最短距離
SELECT
  b.name AS redevelopment_name,
  r.name AS road_name,
  ROUND(ST_Distance(b.geom::geography, r.geom::geography)::numeric, 2) AS distance_m
FROM buildings AS b
JOIN roads AS r
  ON b.year = 2026
 AND r.year = 2026
WHERE b.status = '再開発予定'
ORDER BY distance_m ASC;

-- 3. buildings / roads を横断した年次別件数
SELECT year, layer_type, status, feature_count
FROM (
  SELECT year, 'buildings' AS layer_type, status, COUNT(*) AS feature_count
  FROM buildings
  GROUP BY year, status
  UNION ALL
  SELECT year, 'roads' AS layer_type, status, COUNT(*) AS feature_count
  FROM roads
  GROUP BY year, status
) AS summary
ORDER BY year, layer_type, status;

-- 4. GeoJSON 出力用 buildings
SELECT json_build_object(
  'type', 'FeatureCollection',
  'features', json_agg(
    json_build_object(
      'type', 'Feature',
      'geometry', ST_AsGeoJSON(geom)::json,
      'properties', json_build_object(
        'id', id,
        'name', name,
        'status', status,
        'year', year,
        'description', description
      )
    )
  )
) AS feature_collection
FROM buildings;

-- 5. GeoJSON 出力用 roads
SELECT json_build_object(
  'type', 'FeatureCollection',
  'features', json_agg(
    json_build_object(
      'type', 'Feature',
      'geometry', ST_AsGeoJSON(geom)::json,
      'properties', json_build_object(
        'id', id,
        'name', name,
        'status', status,
        'year', year,
        'description', description
      )
    )
  )
) AS feature_collection
FROM roads;

-- 6. coffee_shops のカテゴリ別件数
SELECT
  category,
  COUNT(*) AS shop_count
FROM coffee_shops
GROUP BY category
ORDER BY shop_count DESC, category ASC;

-- 7. 自由が丘一丁目29番地区代表点から近い珈琲屋 10 件
SELECT
  c.name,
  c.category,
  ROUND(ST_Distance(c.geom::geography, b.geom::geography)::numeric, 1) AS distance_m
FROM coffee_shops AS c
JOIN buildings AS b
  ON b.name = '自由が丘一丁目29番地区'
ORDER BY distance_m ASC
LIMIT 10;

-- 8. GeoJSON 出力用 coffee_shops
SELECT json_build_object(
  'type', 'FeatureCollection',
  'features', json_agg(
    json_build_object(
      'type', 'Feature',
      'geometry', ST_AsGeoJSON(geom)::json,
      'properties', json_build_object(
        'id', id,
        'source_id', source_id,
        'name', name,
        'address', address,
        'category', category,
        'tags', tags,
        'description', description
      )
    )
  )
) AS feature_collection
FROM coffee_shops;
