#!/usr/bin/env python3

import csv
import json
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ZIP_PATH = ROOT / "data/plateau/13110_meguro-ku_pref_2025_citygml_1_op.zip"
COFFEE_PATH = ROOT / "data/coffee_shops.csv"
HOME_PATH = ROOT / "data/home.csv"
OUT_PATH = ROOT / "data/plateau/jiyugaoka_plateau_buildings.geojson"
META_PATH = ROOT / "data/plateau/jiyugaoka_plateau_buildings.meta.json"

NS = {
    "bldg": "http://www.opengis.net/citygml/building/2.0",
    "gml": "http://www.opengis.net/gml",
}

LAT_PADDING = 0.0012
LON_PADDING = 0.0015


def mesh_code(lat: float, lon: float) -> str:
    lat_minutes = lat * 60
    lon_minutes = (lon - 100) * 60
    p = int(lat_minutes // 40)
    a = int(lon_minutes // 60)
    q = int((lat_minutes % 40) // 5)
    r = int((lon_minutes % 60) // 7.5)
    rem_lat = (lat_minutes % 40) % 5
    rem_lon = (lon_minutes % 60) % 7.5
    s = int((rem_lat * 60) // 30)
    t = int((rem_lon * 60) // 45)
    return f"{p:02d}{a:02d}{q}{r}{s}{t}"


def load_points():
    points = []
    with COFFEE_PATH.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            points.append(
                {
                    "name": row["name"],
                    "latitude": float(row["latitude"]),
                    "longitude": float(row["longitude"]),
                    "kind": "coffee_shop",
                }
            )

    with HOME_PATH.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            points.append(
                {
                    "name": row["name"],
                    "latitude": float(row["latitude"]),
                    "longitude": float(row["longitude"]),
                    "kind": "home",
                }
            )

    return points


def build_bbox(points):
    min_lat = min(point["latitude"] for point in points) - LAT_PADDING
    max_lat = max(point["latitude"] for point in points) + LAT_PADDING
    min_lon = min(point["longitude"] for point in points) - LON_PADDING
    max_lon = max(point["longitude"] for point in points) + LON_PADDING
    return min_lat, max_lat, min_lon, max_lon


def bbox_intersects(coords, bbox):
    min_lat, max_lat, min_lon, max_lon = bbox
    lats = [lat for lon, lat in coords]
    lons = [lon for lon, lat in coords]
    return not (
        max(lats) < min_lat
        or min(lats) > max_lat
        or max(lons) < min_lon
        or min(lons) > max_lon
    )


def parse_poslist(text):
    values = [float(value) for value in text.strip().split()]
    triples = list(zip(values[0::3], values[1::3], values[2::3]))
    return triples


def extract_coords(triples):
    coords = [(lon, lat) for lat, lon, _z in triples]
    if coords and coords[0] != coords[-1]:
        coords.append(coords[0])
    return coords


def extract_building(building, source_file, bbox):
    roof = building.find(".//bldg:lod0RoofEdge//gml:posList", NS)
    if roof is None or not roof.text:
        return None

    triples = parse_poslist(roof.text)
    coords = extract_coords(triples)
    if len(coords) < 4 or not bbox_intersects(coords, bbox):
        return None

    measured_height = building.findtext("bldg:measuredHeight", default="", namespaces=NS)
    storeys = building.findtext("bldg:storeysAboveGround", default="", namespaces=NS)
    usage = building.findtext("bldg:usage", default="", namespaces=NS)
    building_class = building.findtext("bldg:class", default="", namespaces=NS)

    lod1_poslists = building.findall(".//bldg:lod1Solid//gml:posList", NS)
    elevations = []
    for poslist in lod1_poslists:
        if poslist.text:
            elevations.extend(z for _lat, _lon, z in parse_poslist(poslist.text))

    base_elevation = min(elevations) if elevations else None
    top_elevation = max(elevations) if elevations else None
    estimated_height = (
        round(top_elevation - base_elevation, 3)
        if base_elevation is not None and top_elevation is not None
        else None
    )

    return {
        "type": "Feature",
        "properties": {
            "gml_id": building.attrib.get("{http://www.opengis.net/gml}id"),
            "source_file": source_file,
            "measured_height_m": float(measured_height) if measured_height else None,
            "estimated_height_m": estimated_height,
            "base_elevation_m": round(base_elevation, 3) if base_elevation is not None else None,
            "top_elevation_m": round(top_elevation, 3) if top_elevation is not None else None,
            "storeys_above_ground": int(storeys) if storeys.isdigit() else None,
            "usage_code": usage or None,
            "class_code": building_class or None,
        },
        "geometry": {
            "type": "Polygon",
            "coordinates": [coords],
        },
    }


def main():
    if not ZIP_PATH.exists():
        raise SystemExit(f"missing ZIP: {ZIP_PATH}")

    points = load_points()
    bbox = build_bbox(points)

    mesh_codes = sorted({mesh_code(point["latitude"], point["longitude"]) for point in points})
    building_files = [f"udx/bldg/{code}_bldg_6697_op.gml" for code in mesh_codes]

    features = []
    used_files = []
    with zipfile.ZipFile(ZIP_PATH) as archive:
        available = set(archive.namelist())
        for file_name in building_files:
            if file_name not in available:
                continue
            used_files.append(file_name)
            with archive.open(file_name) as handle:
                for _event, element in ET.iterparse(handle, events=("end",)):
                    if element.tag == f"{{{NS['bldg']}}}Building":
                        feature = extract_building(element, file_name, bbox)
                        if feature:
                            features.append(feature)
                        element.clear()

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    geojson = {
        "type": "FeatureCollection",
        "name": "jiyugaoka_plateau_buildings",
        "crs": {"type": "name", "properties": {"name": "EPSG:4326"}},
        "features": features,
    }
    OUT_PATH.write_text(json.dumps(geojson, ensure_ascii=False), encoding="utf-8")

    meta = {
        "source_zip": str(ZIP_PATH.relative_to(ROOT)),
        "bbox": {
            "min_lat": bbox[0],
            "max_lat": bbox[1],
            "min_lon": bbox[2],
            "max_lon": bbox[3],
        },
        "input_points": len(points),
        "mesh_codes": mesh_codes,
        "used_files": used_files,
        "feature_count": len(features),
    }
    META_PATH.write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"wrote {len(features)} features to {OUT_PATH}")


if __name__ == "__main__":
    main()
