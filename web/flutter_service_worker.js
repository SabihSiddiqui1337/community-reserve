// KILL SWITCH for stale Flutter service workers.
//
// Earlier builds registered a service worker that aggressively cached the app,
// so old builds kept being served (e.g. the bottom nav hidden behind the
// Firebase emulator banner). This build ships WITHOUT a service worker
// (--pwa-strategy=none). When a browser that still has the old worker checks
// this URL for updates, it installs THIS script instead, which immediately
// clears all caches, unregisters itself, and reloads every open tab — leaving
// a clean, worker-free app.
self.addEventListener('install', function () {
  self.skipWaiting();
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    (async function () {
      try {
        const keys = await caches.keys();
        await Promise.all(keys.map(function (k) { return caches.delete(k); }));
      } catch (e) {}
      try {
        await self.registration.unregister();
      } catch (e) {}
      try {
        const clients = await self.clients.matchAll({ type: 'window' });
        clients.forEach(function (c) { c.navigate(c.url); });
      } catch (e) {}
    })()
  );
});

// Never serve from cache — always hit the network.
self.addEventListener('fetch', function () {});
