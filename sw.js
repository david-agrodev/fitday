// FITDay Service Worker
// Versão do cache — incremente ao fazer deploy para forçar atualização
const CACHE_NAME = 'fitday-v1';

// Arquivos para cache offline
const ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  // Fonts (opcionais — se quiser cache local, adicione abaixo)
  // 'https://fonts.googleapis.com/...'
];

// ── INSTALL: cache dos assets estáticos ──────────────────────────────────
self.addEventListener('install', (event) => {
  console.log('[SW] Instalando FITDay v1...');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[SW] Cacheando assets...');
      return cache.addAll(ASSETS);
    }).then(() => self.skipWaiting())
  );
});

// ── ACTIVATE: limpa caches antigos ───────────────────────────────────────
self.addEventListener('activate', (event) => {
  console.log('[SW] Ativando...');
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => {
            console.log('[SW] Removendo cache antigo:', key);
            return caches.delete(key);
          })
      )
    ).then(() => self.clients.claim())
  );
});

// ── FETCH: estratégia Cache-First com fallback network ───────────────────
self.addEventListener('fetch', (event) => {
  // Ignora requisições não-GET e requests de API externa
  if (event.request.method !== 'GET') return;
  if (event.request.url.includes('supabase.co')) return; // API sempre online
  if (event.request.url.includes('fonts.googleapis.com')) return; // Fonts online

  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached;

      // Não está em cache → busca na rede e salva
      return fetch(event.request).then((response) => {
        if (!response || response.status !== 200 || response.type !== 'basic') {
          return response;
        }
        const toCache = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, toCache));
        return response;
      }).catch(() => {
        // Offline e sem cache → retorna página principal como fallback
        if (event.request.mode === 'navigate') {
          return caches.match('/index.html');
        }
      });
    })
  );
});

// ── BACKGROUND SYNC (futuro) ─────────────────────────────────────────────
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-walks') {
    console.log('[SW] Sincronizando caminhadas pendentes...');
    // TODO: sincronizar dados offline com Supabase
  }
});

// ── PUSH NOTIFICATIONS (futuro) ──────────────────────────────────────────
self.addEventListener('push', (event) => {
  const data = event.data?.json() || {};
  const options = {
    body: data.body || 'Lembrete FITDay',
    icon: '/icons/icon-192.png',
    badge: '/icons/icon-72.png',
    vibrate: [100, 50, 100],
    data: { url: data.url || '/' }
  };
  event.waitUntil(
    self.registration.showNotification(data.title || 'FITDay', options)
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow(event.notification.data.url)
  );
});
