import "./styles.css";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import points from "../data/buildings.json";

const years = [2023, 2025, 2026];
const center = [35.607745, 139.668694];

const palette = {
  "低層商業": {
    color: "#38bdf8",
    border: "#e0f2fe",
    panel: "border-sky-400/50 bg-sky-400/10",
  },
  "新築": {
    color: "#f59e0b",
    border: "#fef3c7",
    panel: "border-amber-400/50 bg-amber-400/10",
  },
  "再開発予定": {
    color: "#fb7185",
    border: "#ffe4e6",
    panel: "border-rose-400/50 bg-rose-400/10",
  },
  "道路拡幅": {
    color: "#34d399",
    border: "#d1fae5",
    panel: "border-emerald-400/50 bg-emerald-400/10",
  },
};

let activeYear = 2026;
let map;

function getVisiblePoints() {
  return points
    .filter((point) => point.year <= activeYear)
    .sort((a, b) => a.year - b.year);
}

function getYearLabel() {
  if (activeYear === 2023) return "低層中心";
  if (activeYear === 2025) return "新築混在";
  return "駅前再編";
}

function markerIcon(point) {
  const style = palette[point.status];
  return L.divIcon({
    className: "custom-marker-shell",
    html: `<span class="custom-marker" style="background:${style.color}; border-color:${style.border}"></span>`,
    iconSize: [20, 20],
    iconAnchor: [10, 10],
  });
}

function render() {
  const visiblePoints = getVisiblePoints();

  document.querySelector("#app").innerHTML = `
    <main class="min-h-screen overflow-hidden">
      <section class="relative isolate">
        <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_left,_rgba(244,114,182,0.18),_transparent_28%),radial-gradient(circle_at_bottom_right,_rgba(45,212,191,0.15),_transparent_25%),linear-gradient(160deg,_#0c0a09,_#1c1917_55%,_#0a0a0a)]"></div>
        <div class="absolute inset-0 opacity-20 [background-image:linear-gradient(rgba(255,255,255,0.05)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.05)_1px,transparent_1px)] [background-size:32px_32px]"></div>
        <div class="relative mx-auto flex min-h-screen max-w-7xl flex-col gap-8 px-6 py-8 lg:px-10">
          <header class="grid gap-6 lg:grid-cols-[1.15fr_0.85fr] lg:items-end">
            <div class="space-y-5">
              <p class="inline-flex w-fit items-center rounded-full border border-white/15 bg-white/8 px-3 py-1 text-xs tracking-[0.24em] text-stone-300 uppercase">
                Jiyugaoka Redevelopment Map PoC
              </p>
              <div class="space-y-3">
                <h1 class="max-w-4xl text-4xl font-semibold leading-none tracking-tight text-stone-50 md:text-6xl">
                  自由が丘の変化を
                  <span class="text-rose-300">実地図</span>
                  で追う
                </h1>
                <p class="max-w-3xl text-base leading-7 text-stone-300 md:text-lg">
                  OpenStreetMap 上に自由が丘駅周辺の PoC 地点を重ね、
                  2023 年の低層商業地から 2026 年の再開発・道路整備までを
                  ブラウザで直接確認できるページ。
                </p>
              </div>
            </div>
            <div class="grid gap-4 rounded-[2rem] border border-white/10 bg-black/20 p-5 backdrop-blur">
              <div class="flex items-center justify-between gap-4">
                <div>
                  <p class="text-xs uppercase tracking-[0.22em] text-stone-400">表示年</p>
                  <p class="mt-2 text-4xl font-semibold text-stone-50">${activeYear}</p>
                </div>
                <div class="rounded-2xl border border-rose-400/30 bg-rose-400/10 px-4 py-3 text-right">
                  <p class="text-xs uppercase tracking-[0.18em] text-rose-200">変化の段階</p>
                  <p class="mt-1 text-lg font-medium text-rose-100">${getYearLabel()}</p>
                </div>
              </div>
              <label class="grid gap-3">
                <span class="text-sm text-stone-300">時間スライダー</span>
                <input id="year-slider" type="range" min="0" max="${years.length - 1}" step="1" value="${years.indexOf(activeYear)}" class="accent-rose-400" />
              </label>
              <div class="flex justify-between text-xs text-stone-400">
                ${years.map((year) => `<span>${year}</span>`).join("")}
              </div>
            </div>
          </header>

          <section class="grid gap-8 lg:grid-cols-[1.2fr_0.8fr]">
            <div class="rounded-[2rem] border border-white/10 bg-stone-900/70 p-4 shadow-2xl shadow-black/30 backdrop-blur">
              <div class="overflow-hidden rounded-[1.5rem] border border-white/8">
                <div id="map" class="h-[520px] w-full"></div>
              </div>
              <div class="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-4">
                ${Object.entries(palette)
                  .map(
                    ([label, style]) => `
                      <div class="rounded-2xl border border-white/10 bg-black/20 px-4 py-3 text-sm text-stone-200">
                        <div class="flex items-center gap-3">
                          <span class="legend-dot" style="background:${style.color}; border-color:${style.border}"></span>
                          <span>${label}</span>
                        </div>
                      </div>
                    `,
                  )
                  .join("")}
              </div>
            </div>

            <div class="grid gap-4">
              <div class="rounded-[2rem] border border-white/10 bg-black/25 p-5 backdrop-blur">
                <p class="text-xs uppercase tracking-[0.22em] text-stone-400">このページでできること</p>
                <ul class="mt-4 grid gap-3 text-sm leading-6 text-stone-300">
                  <li>OpenStreetMap 上で PoC 地点の実座標を確認する</li>
                  <li>年次スライダーで 2023→2026 の変化を切り替える</li>
                  <li>SQL、レポート、俯瞰図モックへ直接アクセスする</li>
                </ul>
              </div>
              <div class="rounded-[2rem] border border-white/10 bg-black/25 p-5 backdrop-blur">
                <p class="text-xs uppercase tracking-[0.22em] text-stone-400">成果物リンク</p>
                <div class="mt-4 grid gap-3 text-sm">
                  <a class="rounded-2xl border border-white/10 px-4 py-3 text-stone-200 transition hover:border-rose-300/50 hover:bg-white/5" href="./init.sql">init.sql</a>
                  <a class="rounded-2xl border border-white/10 px-4 py-3 text-stone-200 transition hover:border-rose-300/50 hover:bg-white/5" href="./queries.sql">queries.sql</a>
                  <a class="rounded-2xl border border-white/10 px-4 py-3 text-stone-200 transition hover:border-rose-300/50 hover:bg-white/5" href="./reports/jiyugaoka-change-report.md">Markdown Report</a>
                  <a class="rounded-2xl border border-white/10 px-4 py-3 text-stone-200 transition hover:border-rose-300/50 hover:bg-white/5" href="./screenshots/jiyugaoka-birdseye.svg">Bird's-eye SVG</a>
                </div>
              </div>
              ${visiblePoints
                .map((point) => {
                  const style = palette[point.status];
                  return `
                    <article class="rounded-[1.6rem] border p-4 ${style.panel}">
                      <div class="flex items-start justify-between gap-4">
                        <div>
                          <p class="text-xs uppercase tracking-[0.18em] text-stone-300">${point.status}</p>
                          <h2 class="mt-2 text-xl font-semibold text-stone-50">${point.name}</h2>
                        </div>
                        <span class="rounded-full border border-white/15 px-3 py-1 text-sm text-stone-200">${point.year}</span>
                      </div>
                      <p class="mt-3 text-sm leading-6 text-stone-200">${point.description}</p>
                      <p class="mt-2 text-xs text-stone-300">lon ${point.lon} / lat ${point.lat}</p>
                    </article>
                  `;
                })
                .join("")}
            </div>
          </section>

          <section class="grid gap-4 rounded-[2rem] border border-white/10 bg-black/20 p-6 backdrop-blur lg:grid-cols-3">
            <article>
              <p class="text-xs uppercase tracking-[0.22em] text-stone-400">Data</p>
              <p class="mt-3 text-sm leading-6 text-stone-300">PostGIS の buildings テーブルと整合する JSON をブラウザ表示にも使う。</p>
            </article>
            <article>
              <p class="text-xs uppercase tracking-[0.22em] text-stone-400">Map</p>
              <p class="mt-3 text-sm leading-6 text-stone-300">OpenStreetMap タイルに地点を重ね、実際の位置関係をそのまま読めるようにした。</p>
            </article>
            <article>
              <p class="text-xs uppercase tracking-[0.22em] text-stone-400">Narrative</p>
              <p class="mt-3 text-sm leading-6 text-stone-300">QGIS と SQL の成果物へ移動しながら、街の変化を文章で補助できる構成にした。</p>
            </article>
          </section>
        </div>
      </section>
    </main>
  `;

  initializeMap(visiblePoints);

  const slider = document.querySelector("#year-slider");
  slider.addEventListener("input", (event) => {
    activeYear = years[Number(event.target.value)];
    render();
  });
}

function initializeMap(visiblePoints) {
  if (map) {
    map.remove();
  }

  map = L.map("map", {
    zoomControl: true,
    scrollWheelZoom: true,
  }).setView(center, 17);

  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  }).addTo(map);

  visiblePoints.forEach((point) => {
    const marker = L.marker([point.lat, point.lon], {
      icon: markerIcon(point),
      title: point.name,
    }).addTo(map);

    marker.bindPopup(`
      <div class="popup-card">
        <strong>${point.name}</strong><br/>
        <span>${point.status} / ${point.year}</span><br/>
        <span>${point.description}</span>
      </div>
    `);
  });
}

render();
