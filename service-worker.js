const CACHE='atlas-training-mobile-v4-1';
const CORE=['./','./index.html','./manifest.webmanifest','./icon-192.png','./icon-512.png'];
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(x=>x.startsWith('atlas-training-')&&x!==CACHE).map(x=>caches.delete(x)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{
 const req=event.request;
 if(req.method!=='GET'||new URL(req.url).origin!==self.location.origin)return;
 if(req.mode==='navigate'){
   event.respondWith(fetch(req).then(response=>{if(response.ok){let copy=response.clone();caches.open(CACHE).then(c=>c.put(req,copy));}return response}).catch(()=>caches.match(req).then(x=>x||caches.match('./index.html'))));
   return;
 }
 event.respondWith(caches.match(req).then(hit=>hit||fetch(req).then(response=>{if(response.ok){let copy=response.clone();caches.open(CACHE).then(c=>c.put(req,copy));}return response})));
});
