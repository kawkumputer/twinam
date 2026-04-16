'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"app-ads.txt": "7f5b135c8df1ff77f909d48f8b149f8e",
"assets/AssetManifest.bin": "de89bb8288d26872d52e0a1dea6cde31",
"assets/AssetManifest.bin.json": "028f8a6ae9c310a40b675149829f1ee1",
"assets/assets/cry-1.mp4": "872fe90489e5bf38b5c9ec380baa4ec9",
"assets/assets/cry-2.mp4": "cb9d20ed012972b4909ae139190b6beb",
"assets/assets/excited-1.mp4": "3517d471ca147012d81a334d52896f1c",
"assets/assets/excited-2.mp4": "4cb1a794fcae845df5ef144168fdd942",
"assets/assets/excited-3.mp4": "49b53a1c66cb85c0191743181064aa8a",
"assets/assets/excited-4.mp4": "3517d471ca147012d81a334d52896f1c",
"assets/assets/excited-two-twin.mp4": "88c1786456a6f9cee79a1fd6ac8290bc",
"assets/assets/happy-avatar.jpeg": "c0077dfee82c754edf75f270c1df3dc6",
"assets/assets/idle-happy.mp4": "98d2d8871bab88963a53861da7a1cc1c",
"assets/assets/idle-neutre.mp4": "f875ab49a7f34b9210ccf6f265a777eb",
"assets/assets/idle-sad.mp4": "15412fc923a554cc76f976466329425c",
"assets/assets/logo.jpeg": "8a2ef93a375f69deea4ed4448770caec",
"assets/assets/neutral-1.mp4": "66e81cab9acb9f686ca243ac414a8d77",
"assets/assets/neutral-2.mp4": "8c89e83167b17e025c38a4b50bdb8e74",
"assets/assets/neutral-avatar.jpeg": "6de62659d8018c90c9d6aa6fe58332f5",
"assets/assets/neutral-two-twin.mp4": "742a8aff6de41a08e78e002a54006654",
"assets/assets/sad-avatar.jpeg": "e3eaa347fb30d94f9c8aae85938b30dc",
"assets/assets/Two-twin-with-hug.mp4": "7092b8ee6a2ec005e8c7b6302d1e72e7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "c3f055e44fdc77cd451203f863dd82f3",
"assets/NOTICES": "15218ca69ca1e8cfefc7dfa87bf83822",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "8a2ef93a375f69deea4ed4448770caec",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "3fd2dbf0f7c4415d73b42169312b7c6b",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "4875109f95a770c67d7640ad43fa713a",
"/": "4875109f95a770c67d7640ad43fa713a",
"main.dart.js": "2a21e8a0ce4295a30679e9a0734a6464",
"manifest.json": "dde0af3340f60bd7a607642a9da083e9",
"splash/img/dark-1x.png": "94f3df58308b3b96c6b7045024aaaab0",
"splash/img/dark-2x.png": "9ed83724e4238cc8c0f4b4f93b8c20f7",
"splash/img/dark-3x.png": "79fa948693d73eac01acf347011adf7f",
"splash/img/dark-4x.png": "7e291d5e28f0532744a64ac8bdd0c040",
"splash/img/light-1x.png": "94f3df58308b3b96c6b7045024aaaab0",
"splash/img/light-2x.png": "9ed83724e4238cc8c0f4b4f93b8c20f7",
"splash/img/light-3x.png": "79fa948693d73eac01acf347011adf7f",
"splash/img/light-4x.png": "7e291d5e28f0532744a64ac8bdd0c040",
"version.json": "a0c6393691ee52f0a34a6149b6617802"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
