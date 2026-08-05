// Service Worker — PWA 离线缓存
const CACHE = 'wms-v2';
const URLS = [
  '/',
  '/static/index.html',
  '/static/manifest.json',
  '/static/logo.jpg',
  '/static/vue.global.prod.js',
  '/static/report.html',
  '/static/doc.html',
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(URLS)));
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request))
  );
});
