{{flutter_js}}
{{flutter_build_config}}

// No serviceWorkerSettings: Flutter's own worker is a deprecated stub that
// unregisters itself, and on the same scope it would remove the frame cache.
_flutter.loader.load();

// Keep the frames offline for a weak venue network. Not on the dev server
// (frames are being edited there) nor on the guest gallery (it shows none).
if ('serviceWorker' in navigator && location.hostname !== 'localhost' &&
    !location.hash.startsWith('#/gallery/')) {
  // One cache per build. The token expands to a quoted build number plus a
  // comment with an apostrophe; inside a template literal neither that nor a
  // later Flutter dropping the token can break the page.
  const build = `{{flutter_service_worker_version}}`.match(/\d+/)?.[0] ?? '0';
  // Ask whichever worker controls the page to fetch every frame. Asked again
  // when a new build's worker takes over: it starts with an empty cache.
  const warmUp = () => navigator.serviceWorker.controller?.postMessage(
    `assets/assets/frames/${window.appFlavor}/`);
  navigator.serviceWorker.addEventListener('controllerchange', warmUp);
  navigator.serviceWorker
    .register(`frame_cache_sw.js?v=${build}`)
    .then(() => navigator.serviceWorker.ready)
    .then(warmUp)
    .catch((error) => console.warn('Frame cache unavailable:', error));
}
