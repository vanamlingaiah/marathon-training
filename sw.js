// Simple offline cache for the marathon training app.
// Bump CACHE_VERSION whenever you update plans so phones fetch the new files.
const CACHE_VERSION = 'marathon-v5';

const ASSETS = [
  'index.html',
  'manifest.json',
  'icons/icon-180.png',
  'icons/icon-192.png',
  'icons/icon-512.png',
  'plans/week-20.html',
  'plans/week-21.html',
  'plans/week-22.html',
  'plans/week-23.html',
  'plans/week-24.html',
  'plans/week-25.html',
  'plans/week-26.html',
  'plans/week-27.html',
  'plans/week-28.html',
  'plans/week-29.html',
  'plans/week-30.html',
  'plans/week-31.html',
  'plans/hr-zones.html'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) => cache.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_VERSION).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Cache-first: instant loads, works offline. Falls back to network for anything uncached (e.g. fonts).
self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request).catch(() => cached))
  );
});
