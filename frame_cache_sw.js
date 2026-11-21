// Serves the bundled frames from Cache Storage so the booth keeps working on a
// weak venue network. One cache per build (?v=); older ones are dropped.
const CACHE = `frames-${new URL(location.href).searchParams.get('v')}`;

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (key.startsWith('frames-') && key !== CACHE) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});

async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request, { ignoreVary: true });
  if (cached) return cached;
  const response = await fetch(request);
  // A full disk must not stop the frame from showing.
  if (response.status === 200) {
    await cache.put(request, response.clone()).catch(() => {});
  }
  return response;
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method === 'GET' &&
      new URL(request.url).pathname.includes('/assets/frames/')) {
    event.respondWith(cacheFirst(request));
  }
});

// The page sends its flavor's frame folder: download every frame listed in its
// data.json, and its picker thumbnail, once, so all of them are here before the
// network drops.
self.addEventListener('message', (event) => {
  event.waitUntil((async () => {
    const root = new URL(event.data, self.registration.scope);
    const data = await (await cacheFirst(new Request(new URL('data.json', root)))).json();
    for (const image of data.images ?? []) {
      for (const path of [`thumbnails/${image.filename}`, image.filename]) {
        await cacheFirst(new Request(new URL(path, root))).catch(() => {});
      }
    }
  })().catch((error) => console.warn('Frame warm-up stopped:', error)));
});
